def test_create_shift(client, headers):
    payload = {
        "name": "Morning Shift",
        "start_time": "08:00",
        "end_time": "16:00",
        "weekend_days": [5, 6],
        "before_start_time": "07:00",
        "after_start_time": "08:15",
        "before_end_time": "15:45",
        "after_end_time": "17:00",
        "max_attendance_time": "09:00",
        "is_night_shift": False,
        "accept_overtime": True,
    }
    response = client.post("/api/shifts/", json=payload, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Morning Shift"
    assert data["start_time"] == "08:00"


def test_get_shifts(client, headers):
    payload = {
        "name": "Another Shift",
        "start_time": "09:00",
        "end_time": "17:00",
        "weekend_days": [5, 6],
        "before_start_time": "08:00",
        "after_start_time": "09:15",
        "before_end_time": "16:45",
        "after_end_time": "18:00",
        "max_attendance_time": "10:00",
        "is_night_shift": False,
        "accept_overtime": True,
    }
    client.post("/api/shifts/", json=payload, headers=headers)
    
    response = client.get("/api/shifts/", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1


def test_update_shift(client, headers):
    # First create a shift to update
    payload = {
        "name": "Evening Shift",
        "start_time": "16:00",
        "end_time": "00:00",
        "weekend_days": [5, 6],
        "before_start_time": "15:00",
        "after_start_time": "16:15",
        "before_end_time": "23:45",
        "after_end_time": "01:00",
        "max_attendance_time": "17:00",
        "is_night_shift": True,
        "accept_overtime": True,
    }
    create_resp = client.post("/api/shifts/", json=payload, headers=headers)
    assert create_resp.status_code == 201
    shift_id = create_resp.json()["id"]

    update_payload = {
        "name": "Updated Evening Shift",
        "after_start_time": "16:30",
    }
    update_resp = client.put(f"/api/shifts/{shift_id}", json=update_payload, headers=headers)
    assert update_resp.status_code == 200
    data = update_resp.json()
    assert data["name"] == "Updated Evening Shift"
    assert data["after_start_time"] == "16:30"


def test_delete_shift(client, headers):
    payload = {
        "name": "Temp Shift",
        "start_time": "10:00",
        "end_time": "18:00",
        "weekend_days": [5, 6],
        "before_start_time": "09:00",
        "after_start_time": "10:15",
        "before_end_time": "17:45",
        "after_end_time": "19:00",
        "max_attendance_time": "11:00",
        "is_night_shift": False,
        "accept_overtime": True,
    }
    create_resp = client.post("/api/shifts/", json=payload, headers=headers)
    assert create_resp.status_code == 201
    shift_id = create_resp.json()["id"]

    delete_resp = client.delete(f"/api/shifts/{shift_id}", headers=headers)
    assert delete_resp.status_code == 200

    get_resp = client.get(f"/api/shifts/{shift_id}", headers=headers)
    assert get_resp.status_code == 404
