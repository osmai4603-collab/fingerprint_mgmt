from datetime import time
from pydantic import BaseModel
from typing import List, Optional


class ShiftBase(BaseModel):
    name: str
    start_time: time
    end_time: time
    weekend_days: Optional[List[int]] = None
    before_start_time: time = time(0, 0)
    after_start_time: time = time(0, 0)
    before_end_time: time = time(0, 0)
    after_end_time: time = time(0, 0)
    max_attendance_time: time = time(0, 0)
    is_night_shift: bool = False
    accept_overtime: bool = True


class ShiftCreate(ShiftBase):
    pass


class ShiftUpdate(BaseModel):
    name: Optional[str] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    weekend_days: Optional[List[int]] = None
    before_start_time: Optional[time] = None
    after_start_time: Optional[time] = None
    before_end_time: Optional[time] = None
    after_end_time: Optional[time] = None
    max_attendance_time: Optional[time] = None
    is_night_shift: Optional[bool] = None
    accept_overtime: Optional[bool] = None


class ShiftResponse(ShiftBase):
    id: int

    class Config:
        from_attributes = True
