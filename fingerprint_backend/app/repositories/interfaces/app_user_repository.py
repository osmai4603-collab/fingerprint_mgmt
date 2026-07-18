from abc import ABC, abstractmethod
from typing import Optional
from app.models.app_user import AppUser
from app.schemas.auth import CreateUserRequest, UpdateUserRequest


class AppUserRepository(ABC):
    @abstractmethod
    def get_all(self) -> list[AppUser]: ...

    @abstractmethod
    def get_by_id(self, user_id: int) -> Optional[AppUser]: ...

    @abstractmethod
    def get_by_username(self, username: str) -> Optional[AppUser]: ...

    @abstractmethod
    def create(self, request: CreateUserRequest, password_hash: str) -> AppUser: ...

    @abstractmethod
    def update(self, user_id: int, request: UpdateUserRequest) -> Optional[AppUser]: ...

    @abstractmethod
    def delete(self, user_id: int) -> bool: ...

    @abstractmethod
    def exists_by_username(self, username: str, exclude_id: Optional[int] = None) -> bool: ...

    @abstractmethod
    def change_password(self, user_id: int, new_password_hash: str) -> bool: ...
