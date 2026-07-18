from abc import ABC, abstractmethod
from typing import Optional
from app.models.biometric_device import BiometricDevice
from app.schemas.device import DeviceCreate, DeviceUpdate


class BiometricDeviceRepository(ABC):
    @abstractmethod
    def get_all(self) -> list[BiometricDevice]: ...

    @abstractmethod
    def get_by_id(self, device_id: int) -> Optional[BiometricDevice]: ...

    @abstractmethod
    def get_by_ip(self, ip_address: str) -> Optional[BiometricDevice]: ...

    @abstractmethod
    def create(self, data: DeviceCreate) -> BiometricDevice: ...

    @abstractmethod
    def update(self, device_id: int, data: DeviceUpdate) -> Optional[BiometricDevice]: ...

    @abstractmethod
    def delete(self, device_id: int) -> bool: ...

    @abstractmethod
    def exists_by_ip(self, ip_address: str, exclude_id: Optional[int] = None) -> bool: ...
