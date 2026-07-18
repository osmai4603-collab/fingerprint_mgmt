import os
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Override the database name for testing BEFORE app imports
os.environ["DB_NAME"] = "fingerprint_test_db"
os.environ["JWT_SECRET"] = "test-secret"

from sqlalchemy import create_engine, text

# Create test database if it doesn't exist BEFORE app imports
default_url = f"postgresql://postgres:postgres@localhost:5432/postgres"
try:
    default_engine = create_engine(default_url, isolation_level="AUTOCOMMIT")
    with default_engine.connect() as conn:
        result = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname = 'fingerprint_test_db'"))
        if not result.scalar():
            conn.execute(text(f"CREATE DATABASE fingerprint_test_db"))
except Exception as e:
    print(f"Error checking/creating test database: {e}")

from app.config.settings import get_settings
from app.config.database import Base, get_db
from app.main import app
from fastapi.testclient import TestClient

settings = get_settings()

engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="session", autouse=True)
def setup_database():
    """Create test database and tables before any tests run."""
    default_url = f"postgresql://{settings.DB_USER}:{settings.DB_PASSWORD}@{settings.DB_HOST}:{settings.DB_PORT}/postgres"
    default_engine = create_engine(default_url, isolation_level="AUTOCOMMIT")
    
    try:
        with default_engine.connect() as conn:
            # Check if database exists
            result = conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname = '{settings.DB_NAME}'"))
            if not result.scalar():
                conn.execute(text(f"CREATE DATABASE {settings.DB_NAME}"))
    except Exception as e:
        print(f"Error creating test database: {e}")
        pass
        
    # Create tables
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    # Seed required default data
    with engine.connect() as conn:
        conn.execute(text("INSERT INTO payroll_periods (id, start_date, end_date, is_closed) VALUES (0, '2000-01-01', '2000-01-31', false) ON CONFLICT (id) DO NOTHING;"))
        conn.execute(text("INSERT INTO employees (uid, employee_id, name, role, is_active, created_at, updated_at) VALUES (1, 'admin', 'Administrator', 'admin', true, NOW(), NOW()) ON CONFLICT (uid) DO NOTHING;"))
        conn.execute(text("INSERT INTO app_users (username, password_hash, role, employee_id, is_active, created_at, updated_at) VALUES ('admin', '$2a$10$nKSo5vF.68Ux2mLWH24D5uqAtkEEfXNqMCcvw69ZcfLikc4RIaw/O', 'admin', 1, true, NOW(), NOW()) ON CONFLICT (username) DO NOTHING;"))
        
        # Reset auto-increment sequences so they don't collide with seeded IDs
        conn.execute(text("SELECT setval('employees_uid_seq', (SELECT MAX(uid) FROM employees));"))
        conn.execute(text("SELECT setval('app_users_id_seq', (SELECT MAX(id) FROM app_users));"))
        conn.commit()
    
    yield
    # Optionally drop tables after test session
    # Base.metadata.drop_all(bind=engine)


@pytest.fixture(scope="function")
def db_session():
    """Provides a transactional scope around a series of operations."""
    connection = engine.connect()
    transaction = connection.begin()
    
    session = TestingSessionLocal(bind=connection)
    
    yield session
    
    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture(scope="function")
def client(db_session):
    """Provides a TestClient with overridden get_db dependency."""
    def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()

@pytest.fixture
def auth_token(client):
    login_resp = client.post("/api/auth/login", json={
        "username": "admin",
        "password": "admin123"
    })
    assert login_resp.status_code == 200, "Admin login failed during test setup"
    return login_resp.json()["token"]

@pytest.fixture
def headers(auth_token):
    return {"Authorization": f"Bearer {auth_token}"}
