import json
import asyncio
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.config.database import SessionLocal
from app.repositories.implementations.biometric_device_repository_impl import BiometricDeviceRepositoryImpl
from app.services.zkteco_k40_controller import ZktecoK40Controller
from datetime import datetime

router = APIRouter(prefix="/api/ws", tags=["WebSockets"])

class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[int, list[WebSocket]] = {}
        self.capture_tasks: dict[int, asyncio.Task] = {}

    async def connect(self, websocket: WebSocket, device_id: int):
        await websocket.accept()
        if device_id not in self.active_connections:
            self.active_connections[device_id] = []
        self.active_connections[device_id].append(websocket)

    def disconnect(self, websocket: WebSocket, device_id: int):
        if device_id in self.active_connections:
            if websocket in self.active_connections[device_id]:
                self.active_connections[device_id].remove(websocket)
            if len(self.active_connections[device_id]) == 0:
                if device_id in self.capture_tasks:
                    self.capture_tasks[device_id].cancel()
                    del self.capture_tasks[device_id]

    async def broadcast(self, message: dict, device_id: int):
        if device_id in self.active_connections:
            for connection in self.active_connections[device_id]:
                try:
                    await connection.send_json(message)
                except Exception:
                    pass

manager = ConnectionManager()

def start_live_capture_sync(device_id: int, ip: str, port: int, manager: ConnectionManager, loop: asyncio.AbstractEventLoop):
    from app.models.biometric_device import BiometricDevice
    dummy_device = BiometricDevice(id=device_id, ip_address=ip, port=port)
    controller = ZktecoK40Controller(dummy_device)

    if not controller.connect():
        print(f"Failed to connect to device {device_id} for live capture.")
        return

    print(f"Started live capture for device {device_id}")
    try:
        for att in controller.live_capture(new_timeout=10):
            message = {
                "type": "biometric_data",
                "device_id": device_id,
                "biometric_id": str(att.user_id),
                "is_check_in": True if att.status in [0, 4] else False,
                "timestamp": att.timestamp.isoformat()
            }
            asyncio.run_coroutine_threadsafe(manager.broadcast(message, device_id), loop)
    except Exception as e:
        print(f"Live capture error: {e}")
    finally:
        controller.disconnect()
        print(f"Ended live capture for device {device_id}")


async def start_live_capture_task(device_id: int, ip: str, port: int):
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, start_live_capture_sync, device_id, ip, port, manager, loop)

@router.websocket("/devices")
async def websocket_devices(websocket: WebSocket):
    await websocket.accept()
    registered_device_id = None

    try:
        while True:
            data = await websocket.receive_text()
            try:
                message = json.loads(data)
            except json.JSONDecodeError:
                continue

            msg_type = message.get("type")
            device_id = message.get("device_id")

            if not device_id:
                continue

            if msg_type == "register":
                db = SessionLocal()
                try:
                    device_repo = BiometricDeviceRepositoryImpl(db)
                    device = device_repo.get_by_id(device_id)
                finally:
                    db.close()

                if not device:
                    await websocket.send_json({
                        "type": "error",
                        "message": "Device not found"
                    })
                    continue

                registered_device_id = device_id

                if device_id not in manager.active_connections:
                    manager.active_connections[device_id] = []
                if websocket not in manager.active_connections[device_id]:
                    manager.active_connections[device_id].append(websocket)

                await websocket.send_json({
                    "type": "registered",
                    "device_id": device_id,
                    "message": "Device registered successfully"
                })

                if device_id not in manager.capture_tasks:
                    task = asyncio.create_task(start_live_capture_task(device_id, device.ip_address, device.port))
                    manager.capture_tasks[device_id] = task

            elif msg_type == "heartbeat":
                if registered_device_id == device_id:
                    await websocket.send_json({
                        "type": "heartbeat_ack",
                        "device_id": device_id,
                        "timestamp": datetime.now().isoformat()
                    })

    except WebSocketDisconnect:
        if registered_device_id:
            manager.disconnect(websocket, registered_device_id)
