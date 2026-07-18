from typing import Optional
from sqlalchemy.orm import Session
from app.models.app_user import AppUser
from app.schemas.auth import CreateUserRequest, UpdateUserRequest
from app.repositories.interfaces.app_user_repository import AppUserRepository


class AppUserRepositoryImpl(AppUserRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[AppUser]:
        return self.db.query(AppUser).all()

    def get_by_id(self, user_id: int) -> Optional[AppUser]:
        return self.db.query(AppUser).filter(AppUser.id == user_id).first()

    def get_by_username(self, username: str) -> Optional[AppUser]:
        return self.db.query(AppUser).filter(AppUser.username == username).first()

    def create(self, request: CreateUserRequest, password_hash: str) -> AppUser:
        user = AppUser(
            username=request.username,
            password_hash=password_hash,
            role=request.role,
            employee_id=request.employee_id,
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def update(self, user_id: int, request: UpdateUserRequest) -> Optional[AppUser]:
        user = self.get_by_id(user_id)
        if not user:
            return None
        if request.username is not None:
            user.username = request.username
        if request.role is not None:
            user.role = request.role
        if request.employee_id is not None:
            user.employee_id = request.employee_id
        if request.is_active is not None:
            user.is_active = request.is_active
        self.db.commit()
        self.db.refresh(user)
        return user

    def delete(self, user_id: int) -> bool:
        user = self.get_by_id(user_id)
        if not user:
            return False
        self.db.delete(user)
        self.db.commit()
        return True

    def exists_by_username(self, username: str, exclude_id: Optional[int] = None) -> bool:
        query = self.db.query(AppUser).filter(AppUser.username == username)
        if exclude_id is not None:
            query = query.filter(AppUser.id != exclude_id)
        return query.first() is not None

    def change_password(self, user_id: int, new_password_hash: str) -> bool:
        user = self.get_by_id(user_id)
        if not user:
            return False
        user.password_hash = new_password_hash
        self.db.commit()
        return True
