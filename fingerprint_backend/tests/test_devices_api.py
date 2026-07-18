def test_create_device(client, headers):
    payload = {
        "name": "Front Door Scanner",
        "ip_address": "192.168.1.100",
        "device_type": "ZK",
        
    }
    response = client.post("/api/devices/", json=payload, headers=headers)
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Front Door Scanner"
    assert data["ip_address"] == "192.168.1.100"


def test_create_device_duplicate_ip(client, headers):
    payload = {
        "name": "Back Door Scanner",
        "ip_address": "192.168.1.101",
        "device_type": "ZK",
    }
    res1 = client.post("/api/devices/", json=payload, headers=headers)
    assert res1.status_code == 201

    payload_duplicate = {
        "name": "Duplicate IP Scanner",
        "ip_address": "192.168.1.101",
        "device_type": "ZK",
    }
    res2 = client.post("/api/devices/", json=payload_duplicate, headers=headers)
    assert res2.status_code == 409


def test_get_devices(client, headers):
    response = client.get("/api/devices/", headers=headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_update_device(client, headers):
    payload = {
        "name": "Side Door",
        "ip_address": "192.168.1.102", "device_type": "ZK"
    }
    create_resp = client.post("/api/devices/", json=payload, headers=headers)
    device_id = create_resp.json()["id"]

    update_payload = {
        "name": "Main Entrance"
    }
    update_resp = client.put(f"/api/devices/{device_id}", json=update_payload, headers=headers)
    assert update_resp.status_code == 200
    assert update_resp.json()["name"] == "Main Entrance"


def test_delete_device(client, headers):
    payload = {
        "name": "Temp Device",
        "ip_address": "192.168.1.103", "device_type": "ZK"
    }
    create_resp = client.post("/api/devices/", json=payload, headers=headers)
    device_id = create_resp.json()["id"]

    delete_resp = client.delete(f"/api/devices/{device_id}", headers=headers)
    assert delete_resp.status_code == 200
