from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from app.config.settings import get_settings

settings = get_settings()


class JwtUtils:
    @staticmethod
    def generate_token(
        user_id: int,
        username: str,
        role: str,
        employee_id: Optional[int] = None,
    ) -> str:
        payload = {
            "userId": user_id,
            "username": username,
            "role": role,
            "employeeId": employee_id,
            "type": "access",
            "exp": datetime.utcnow() + timedelta(hours=settings.JWT_EXPIRY_HOURS),
            "iat": datetime.utcnow(),
        }
        return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

    @staticmethod
    def generate_refresh_token(
        user_id: int,
        username: str,
        role: str,
        employee_id: Optional[int] = None,
    ) -> str:
        payload = {
            "userId": user_id,
            "username": username,
            "role": role,
            "employeeId": employee_id,
            "type": "refresh",
            "exp": datetime.utcnow() + timedelta(days=settings.JWT_REFRESH_EXPIRY_DAYS),
            "iat": datetime.utcnow(),
        }
        return jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)

    @staticmethod
    def verify_token(token: str) -> Optional[dict]:
        try:
            payload = jwt.decode(
                token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM]
            )
            return payload
        except JWTError:
            return None

    @staticmethod
    def get_user_id_from_token(token: str) -> Optional[int]:
        payload = JwtUtils.verify_token(token)
        if payload:
            return payload.get("userId")
        return None
