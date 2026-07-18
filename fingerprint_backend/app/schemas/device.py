from pydantic import BaseModel
from typing import Optional
from datetime import datetime, date


class DeviceBase(BaseModel):
    name: str
    device_type: str
    ip_address: str
    port: int = 4370


class DeviceCreate(DeviceBase):
    pass


class DeviceUpdate(BaseModel):
    name: Optional[str] = None
    device_type: Optional[str] = None
    ip_address: Optional[str] = None
    port: Optional[int] = None
    is_online: Optional[bool] = None


class DeviceResponse(BaseModel):
    id: int
    name: str
    device_type: str
    ip_address: str
    port: int
    is_online: bool
    last_sync: Optional[datetime] = None
    last_request_date: Optional[date] = None

    class Config:
        from_attributes = True


class DeviceStatusResponse(BaseModel):
    device_id: int
    name: str
    ip_address: str
    port: int
    is_online: bool
    last_sync: Optional[datetime] = None
    last_request_date: Optional[date] = None

    class Config:
        from_attributes = True
