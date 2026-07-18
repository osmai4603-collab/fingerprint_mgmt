import pytest

def test_create_employee(client, headers):
    payload = {
        "employee_id": "EMP101",
        "name": "John Doe",
        "role": "user"
    }
    response = client.post("/api/employees/", json=payload, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["employee_id"] == "EMP101"
    assert data["name"] == "John Doe"
    assert data["is_active"] == True


def test_create_employee_duplicate(client, headers):
    payload = {
        "employee_id": "EMP102",
        "name": "Jane Doe",
        "role": "user"
    }
    # First request
    res1 = client.post("/api/employees/", json=payload, headers=headers)
    assert res1.status_code == 201
    
    # Try to create with the same employee_id
    response2 = client.post("/api/employees/", json=payload, headers=headers)
    assert response2.status_code == 409


def test_get_employees(client, headers):
    response = client.get("/api/employees/", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    # the admin user is created by migrations, so len should be >= 1
    assert len(data) >= 1


def test_update_employee(client, headers):
    payload = {
        "employee_id": "EMP103",
        "name": "Old Name",
        "role": "user"
    }
    create_resp = client.post("/api/employees/", json=payload, headers=headers)
    emp_uid = create_resp.json()["uid"]
    
    update_payload = {
        "name": "New Name"
    }
    update_resp = client.put(f"/api/employees/{emp_uid}", json=update_payload, headers=headers)
    assert update_resp.status_code == 200
    assert update_resp.json()["name"] == "New Name"


def test_delete_employee(client, headers):
    payload = {
        "employee_id": "EMP104",
        "name": "To Delete",
        "role": "user"
    }
    create_resp = client.post("/api/employees/", json=payload, headers=headers)
    assert create_resp.status_code == 201
    emp_uid = create_resp.json()["uid"]
    
    delete_resp = client.delete(f"/api/employees/{emp_uid}", headers=headers)
    assert delete_resp.status_code == 200
    
    # Try to fetch, might return 404 or the object with is_active=False
    get_resp = client.get(f"/api/employees/{emp_uid}", headers=headers)
    # Depends on implementation, but typically soft-deleted users are either hidden or marked inactive
    if get_resp.status_code == 200:
        assert get_resp.json()["is_active"] == False
    else:
        assert get_resp.status_code == 404
