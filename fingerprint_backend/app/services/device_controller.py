import base64
from abc import ABC, abstractmethod
from pydantic import BaseModel, field_serializer, field_validator
from datetime import datetime
from typing import List, Optional, Iterator


class BiometricUser(BaseModel):
    """Data class for user information retrieved from or sent to a biometric device."""
    uid: Optional[int] = None
    user_id: str
    name: str = ""
    privilege: int = 0
    password: str = ""
    group_id: str = ""
    card: int = 0


class BiometricAttendance(BaseModel):
    """Data class for attendance logs retrieved from a biometric device."""
    user_id: str
    timestamp: datetime
    status: int
    punch_type: int = 0


class BiometricTemplate(BaseModel):
    """Data class for fingerprint/biometric templates."""
    uid: int
    size: int = 0
    valid: int = 1
    template: bytes
    mark: int = 0

    @field_serializer('template')
    def serialize_template(self, value: bytes) -> str:
        return base64.b64encode(value).decode('ascii')

    @field_validator('template', mode='before')
    @classmethod
    def decode_template(cls, value):
        if isinstance(value, str):
            return base64.b64decode(value)
        return value


class BiometricDeviceController(ABC):
    """Abstract Base Class defining the interface for biometric device operations."""

    # ==========================================
    # Connection and Device State Management
    # ==========================================
    
    @abstractmethod
    def connect(self) -> bool:
        """Establishes connection to the device."""
        pass

    @abstractmethod
    def disconnect(self) -> bool:
        """Terminates connection to the device."""
        pass

    @abstractmethod
    def disable_device(self) -> bool:
        """Disables the device for other operations (e.g., during syncing)."""
        pass

    @abstractmethod
    def enable_device(self) -> bool:
        """Enables the device after operations are complete."""
        pass

    @abstractmethod
    def restart(self) -> bool:
        """Restarts the device."""
        pass

    @abstractmethod
    def poweroff(self) -> bool:
        """Powers off the device."""
        pass

    # ==========================================
    # Attendance Management
    # ==========================================

    @abstractmethod
    def get_attendance(self) -> List[BiometricAttendance]:
        """Retrieves all attendance records from the device."""
        pass

    @abstractmethod
    def clear_attendance(self) -> bool:
        """Clears all attendance records from the device."""
        pass

    # ==========================================
    # User Management
    # ==========================================

    @abstractmethod
    def get_users(self) -> List[BiometricUser]:
        """Retrieves all users from the device."""
        pass

    @abstractmethod
    def set_user(self, user: BiometricUser) -> bool:
        """Adds or updates a user on the device."""
        pass

    @abstractmethod
    def delete_user(self, uid: int = 0, user_id: str = '') -> bool:
        """Deletes a user from the device."""
        pass

    # ==========================================
    # Biometric Templates Management
    # ==========================================

    @abstractmethod
    def get_templates(self) -> List[BiometricTemplate]:
        """Retrieves all biometric templates from the device."""
        pass

    @abstractmethod
    def get_user_template(self, uid: int, temp_id: int = 0, user_id: str = '') -> Optional[BiometricTemplate]:
        """Retrieves a specific biometric template for a user."""
        pass

    @abstractmethod
    def save_user_template(self, user: BiometricUser, templates: List[BiometricTemplate]) -> bool:
        """Saves a biometric template for a user."""
        pass

    @abstractmethod
    def delete_user_template(self, uid: int = 0, temp_id: int = 0, user_id: str = '') -> bool:
        """Deletes a specific biometric template."""
        pass

    @abstractmethod
    def enroll_user(self, uid: int = 0, temp_id: int = 0, user_id: str = '') -> bool:
        """Puts the device in enrollment mode for a user."""
        pass

    # ==========================================
    # Device Information and Settings
    # ==========================================

    @abstractmethod
    def get_device_name(self) -> str:
        """Retrieves the device name or model."""
        pass

    @abstractmethod
    def get_serialnumber(self) -> str:
        """Retrieves the device's serial number."""
        pass

    @abstractmethod
    def get_mac(self) -> str:
        """Retrieves the device's MAC address."""
        pass

    @abstractmethod
    def get_firmware_version(self) -> str:
        """Retrieves the firmware version."""
        pass

    @abstractmethod
    def get_platform(self) -> str:
        """Retrieves the device platform/model (e.g., 'K40')."""
        pass

    @abstractmethod
    def get_pin_width(self) -> int:
        """Retrieves the PIN width (number of digits in employee ID)."""
        pass

    @abstractmethod
    def read_sizes(self) -> dict:
        """Reads device memory sizes (users, fingers, records, faces and their capacities)."""
        pass

    @abstractmethod
    def get_network_params(self) -> dict:
        """Retrieves network parameters (IP, Subnet, Gateway)."""
        pass

    @abstractmethod
    def get_time(self) -> datetime:
        """Retrieves the device's current time."""
        pass

    @abstractmethod
    def set_time(self, timestamp: datetime) -> bool:
        """Sets the device's time."""
        pass

    # ==========================================
    # Live Control
    # ==========================================

    @abstractmethod
    def unlock(self, time: int = 3) -> bool:
        """Unlocks the door connected to the device."""
        pass

    @abstractmethod
    def live_capture(self, new_timeout: int = 10) -> Iterator[BiometricAttendance]:
        """Starts real-time live capture of attendance logs."""
        pass

    @abstractmethod
    def test_voice(self, index: int = 0) -> bool:
        """Plays a specific voice prompt on the device."""
        pass

    @abstractmethod
    def clear_data(self) -> bool:
        """Clears all data (users, attendance, templates) from the device."""
        pass
