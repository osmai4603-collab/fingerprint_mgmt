from datetime import datetime
from sqlalchemy.orm import Session
from app.models.biometric_device import BiometricDevice


class SyncFingerprintDataUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, device_id: int) -> dict:
        device = self.db.query(BiometricDevice).filter(BiometricDevice.id == device_id).first()
        if not device:
            raise ValueError(f"Device {device_id} not found")

        device.last_sync = datetime.utcnow()
        self.db.commit()

        return {
            "device_id": device.id,
            "name": device.name,
            "last_sync": device.last_sync.isoformat(),
            "status": "synced",
        }
