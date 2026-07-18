def test_login_success(client, db_session):
    # Ensure default admin user exists (it should be created by 001_init.sql)
    from app.models.app_user import AppUser
    admin_user = db_session.query(AppUser).filter(AppUser.username == 'admin').first()
    assert admin_user is not None
    
    response = client.post("/api/auth/login", json={
        "username": "admin",
        "password": "admin123"
    })
    
    assert response.status_code == 200
    data = response.json()
    assert "token" in data
    assert "refreshToken" in data
    assert "user" in data
    assert data["user"]["username"] == "admin"


def test_login_invalid_password(client):
    response = client.post("/api/auth/login", json={
        "username": "admin",
        "password": "wrongpassword"
    })
    
    assert response.status_code == 401
    assert "detail" in response.json()


def test_token_refresh(client):
    # First login
    login_resp = client.post("/api/auth/login", json={
        "username": "admin",
        "password": "admin123"
    })
    assert login_resp.status_code == 200
    refresh_token = login_resp.json()["refreshToken"]
    
    # Then refresh
    refresh_resp = client.post("/api/auth/refresh", json={
        "refreshToken": refresh_token
    })
    assert refresh_resp.status_code == 200
    data = refresh_resp.json()
    assert "token" in data
    assert "refreshToken" in data


def test_logout(client):
    # First login
    login_resp = client.post("/api/auth/login", json={
        "username": "admin",
        "password": "admin123"
    })
    assert login_resp.status_code == 200
    token = login_resp.json()["token"]
    
    # Logout using header
    logout_resp = client.post("/api/auth/logout", headers={
        "Authorization": f"Bearer {token}"
    })
    assert logout_resp.status_code == 200
