from typing import Optional
from sqlalchemy.orm import Session
from app.models.biometric_device import BiometricDevice
from app.schemas.device import DeviceCreate, DeviceUpdate
from app.repositories.interfaces.biometric_device_repository import BiometricDeviceRepository


class BiometricDeviceRepositoryImpl(BiometricDeviceRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[BiometricDevice]:
        return self.db.query(BiometricDevice).all()

    def get_by_id(self, device_id: int) -> Optional[BiometricDevice]:
        return self.db.query(BiometricDevice).filter(BiometricDevice.id == device_id).first()

    def get_by_ip(self, ip_address: str) -> Optional[BiometricDevice]:
        return self.db.query(BiometricDevice).filter(BiometricDevice.ip_address == ip_address).first()

    def create(self, data: DeviceCreate) -> BiometricDevice:
        device = BiometricDevice(**data.model_dump(), is_online=False)
        self.db.add(device)
        self.db.commit()
        self.db.refresh(device)
        return device

    def update(self, device_id: int, data: DeviceUpdate) -> Optional[BiometricDevice]:
        device = self.get_by_id(device_id)
        if not device:
            return None
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(device, field, value)
        self.db.commit()
        self.db.refresh(device)
        return device

    def delete(self, device_id: int) -> bool:
        device = self.get_by_id(device_id)
        if not device:
            return False
        self.db.delete(device)
        self.db.commit()
        return True

    def exists_by_ip(self, ip_address: str, exclude_id: Optional[int] = None) -> bool:
        query = self.db.query(BiometricDevice).filter(BiometricDevice.ip_address == ip_address)
        if exclude_id is not None:
            query = query.filter(BiometricDevice.id != exclude_id)
        return query.first() is not None
