from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.schemas.employee import EmployeeResponse


class AttendanceLogResponse(BaseModel):
    id: int
    employee_id: Optional[int] = None
    unrecognized_biometric: Optional[str] = None
    device_id: Optional[int] = None
    punch_time: datetime
    employee: Optional[EmployeeResponse] = None

    class Config:
        from_attributes = True


class AttendanceRecordResponse(BaseModel):
    id: int
    employee_id: int
    payroll_period_id: int
    record_date: str
    total_hours: float
    lateness_mins: int
    overtime_mins: int
    is_locked: bool
    flags: Optional[str] = None
    employee: Optional[EmployeeResponse] = None

    class Config:
        from_attributes = True
