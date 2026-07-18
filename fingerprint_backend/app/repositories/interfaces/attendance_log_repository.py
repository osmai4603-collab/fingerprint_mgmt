from abc import ABC, abstractmethod
from typing import Optional
from datetime import datetime
from app.models.attendance import AttendanceLog


class AttendanceLogRepository(ABC):
    @abstractmethod
    def get_by_id(self, log_id: int) -> Optional[AttendanceLog]: ...

    @abstractmethod
    def get_filtered(
        self,
        employee_id: Optional[int] = None,
        device_id: Optional[int] = None,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[AttendanceLog]: ...

    @abstractmethod
    def get_by_employee_and_time_range(
        self,
        employee_id: int,
        start: datetime,
        end: datetime,
    ) -> list[AttendanceLog]: ...

    @abstractmethod
    def get_unrecognized(self) -> list[AttendanceLog]: ...

    @abstractmethod
    def get_duplicate(self, employee_id: int, punch_time: datetime, threshold_minutes: int = 5) -> Optional[AttendanceLog]: ...

    @abstractmethod
    def create(self, employee_id: Optional[int], device_id: Optional[int], punch_time: datetime, unrecognized_biometric: Optional[str] = None) -> AttendanceLog: ...

    @abstractmethod
    def update(self, log_id: int, data: dict) -> Optional[AttendanceLog]: ...

    @abstractmethod
    def delete(self, log_id: int) -> bool: ...
