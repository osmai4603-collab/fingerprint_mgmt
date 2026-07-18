from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class EmployeeFingerprintReportResponse(BaseModel):
    employee_id: int
    employee_name: str
    date: str
    punch1: Optional[datetime] = None
    punch2: Optional[datetime] = None
    punch3: Optional[datetime] = None
    punch4: Optional[datetime] = None
    punch5: Optional[datetime] = None
    punch6: Optional[datetime] = None

    class Config:
        from_attributes = True


class AttendanceSummaryReportResponse(BaseModel):
    employee_id: int
    employee_name: str
    work_hours: float = 0
    overtime_hours: float = 0
    absence_hours: float = 0
    deduction_amount: float = 0

    class Config:
        from_attributes = True


class DetailedDailyReportResponse(BaseModel):
    employee_id: int
    employee_name: str
    date: str
    shift_name: Optional[str] = None
    attendance_time: Optional[datetime] = None
    departure_time: Optional[datetime] = None
    work_hours: float = 0
    overtime_hours: float = 0
    absence_hours: float = 0
    attendance_status: Optional[str] = None

    class Config:
        from_attributes = True
