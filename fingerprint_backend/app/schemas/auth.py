from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    token: str
    refreshToken: str
    user: "UserResponse"


class RefreshRequest(BaseModel):
    refreshToken: str


class CreateUserRequest(BaseModel):
    username: str
    password: str
    role: str = "viewer"
    employee_id: Optional[int] = None


class UpdateUserRequest(BaseModel):
    username: Optional[str] = None
    role: Optional[str] = None
    employee_id: Optional[int] = None
    is_active: Optional[bool] = None


class ChangePasswordRequest(BaseModel):
    new_password: str


class UserResponse(BaseModel):
    id: int
    username: str
    role: str
    employee_id: Optional[int] = None
    is_active: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True
