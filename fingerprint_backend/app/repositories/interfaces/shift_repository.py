from abc import ABC, abstractmethod
from typing import Optional
from app.models.shift import Shift
from app.schemas.shift import ShiftCreate, ShiftUpdate


class ShiftRepository(ABC):
    @abstractmethod
    def get_all(self) -> list[Shift]: ...

    @abstractmethod
    def get_by_id(self, shift_id: int) -> Optional[Shift]: ...

    @abstractmethod
    def get_by_name(self, name: str) -> Optional[Shift]: ...

    @abstractmethod
    def create(self, data: ShiftCreate) -> Shift: ...

    @abstractmethod
    def update(self, shift_id: int, data: ShiftUpdate) -> Optional[Shift]: ...

    @abstractmethod
    def delete(self, shift_id: int) -> bool: ...

    @abstractmethod
    def exists_by_name(self, name: str, exclude_id: Optional[int] = None) -> bool: ...
