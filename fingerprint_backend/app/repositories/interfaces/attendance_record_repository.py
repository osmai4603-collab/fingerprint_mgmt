from abc import ABC, abstractmethod
from typing import Optional
from datetime import date
from app.models.attendance_record import AttendanceRecord


class AttendanceRecordRepository(ABC):
    @abstractmethod
    def get_by_id(self, record_id: int) -> Optional[AttendanceRecord]: ...

    @abstractmethod
    def get_by_employee_and_date(self, employee_id: int, record_date: str) -> Optional[AttendanceRecord]: ...

    @abstractmethod
    def get_by_employee_and_period(self, employee_id: int, period_id: int) -> list[AttendanceRecord]: ...

    @abstractmethod
    def get_by_employee_and_date_range(self, employee_id: int, start_date: str, end_date: str) -> list[AttendanceRecord]: ...

    @abstractmethod
    def get_employee_summary(self, employee_id: int, period_id: int) -> tuple: ...

    @abstractmethod
    def create(self, employee_id: int, payroll_period_id: int, record_date: str) -> AttendanceRecord: ...

    @abstractmethod
    def update(self, record_id: int, data: dict) -> Optional[AttendanceRecord]: ...
