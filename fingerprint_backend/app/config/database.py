from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import sessionmaker
from app.config.settings import get_settings

settings = get_settings()

engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    pool_recycle=1800,
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def _ensure_default_admin():
    from app.models.app_user import AppUser
    from app.utils.password_utils import PasswordUtils
    session = SessionLocal()
    try:
        existing = session.query(AppUser).filter(AppUser.username == "admin").first()
        if existing is None:
            admin = AppUser(
                username="admin",
                password_hash=PasswordUtils.hash_password("admin123"),
                role="admin",
                is_active=True,
            )
            session.add(admin)
            session.commit()
    finally:
        session.close()


def init_database():
    Base.metadata.create_all(bind=engine)
    _ensure_default_admin()

    if settings.MIGRATIONS_DIR:
        from app.services.migration_runner import run_migrations
        run_migrations(engine, settings.MIGRATIONS_DIR, skip_init_schema=True)
