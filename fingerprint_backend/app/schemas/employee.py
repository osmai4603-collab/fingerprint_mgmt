from datetime import datetime
from pydantic import BaseModel
from typing import List, Optional


class EmployeeBase(BaseModel):
    employee_id: str
    name: str
    role: str = "user"
    group_id: Optional[str] = None
    card_no: Optional[int] = None
    default_shift_id: Optional[int] = None
    password: Optional[str] = None


class EmployeeCreate(EmployeeBase):
    pass


class EmployeeUpdate(BaseModel):
    employee_id: Optional[str] = None
    name: Optional[str] = None
    role: Optional[str] = None
    group_id: Optional[str] = None
    card_no: Optional[int] = None
    default_shift_id: Optional[int] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None


class EmployeeResponse(BaseModel):
    uid: int
    employee_id: str
    name: str
    role: str
    group_id: Optional[str] = None
    card_no: Optional[int] = None
    default_shift_id: Optional[int] = None
    is_active: bool

    class Config:
        from_attributes = True


class EmployeeWithShiftResponse(EmployeeResponse):
    shift_name: Optional[str] = None
    shift_start: Optional[str] = None
    shift_end: Optional[str] = None


class EmployeeSummaryResponse(BaseModel):
    employee_uid: int
    employee_id: str
    name: str
    total_working_hours: float = 0.0
    total_late_mins: int = 0
    total_overtime_mins: int = 0
    fingerprint_count: int = 0
    shift_name: Optional[str] = None

    class Config:
        from_attributes = True


class FingerprintResponse(BaseModel):
    id: int
    employee_id: int
    biometric: str
    finger_index: int

    class Config:
        from_attributes = True


class FingerprintCreate(BaseModel):
    biometric: str
    finger_index: int


class FingerprintSearchRequest(BaseModel):
    biometric: str


class FingerprintSearchResponse(BaseModel):
    matched: bool
    employee_uid: Optional[int] = None
    employee_name: Optional[str] = None


class CsvImportRequest(BaseModel):
    csv_content: str


class EmployeeShiftInfo(BaseModel):
    id: int
    name: str
    start_time: str
    end_time: str

    class Config:
        from_attributes = True


class EmployeeFingerprintInfo(BaseModel):
    id: int
    biometric: str
    finger_index: int

    class Config:
        from_attributes = True


class EmployeeAppUserInfo(BaseModel):
    id: int
    username: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True


class EmployeeFullResponse(BaseModel):
    uid: int
    employee_id: str
    name: str
    role: str
    group_id: Optional[str] = None
    card_no: Optional[int] = None
    default_shift_id: Optional[int] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    shift: Optional[EmployeeShiftInfo] = None
    fingerprints: List[EmployeeFingerprintInfo] = []
    app_user: Optional[EmployeeAppUserInfo] = None

    class Config:
        from_attributes = True
