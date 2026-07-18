from abc import ABC, abstractmethod
from typing import Optional
from app.models.employee import Employee
from app.schemas.employee import EmployeeCreate, EmployeeUpdate


class EmployeeRepository(ABC):
    @abstractmethod
    def get_all(self, is_active: Optional[bool] = None) -> list[Employee]: ...

    @abstractmethod
    def get_by_uid(self, uid: int) -> Optional[Employee]: ...

    @abstractmethod
    def get_by_employee_id(self, employee_id: str) -> Optional[Employee]: ...

    @abstractmethod
    def get_by_card_no(self, card_no: int) -> Optional[Employee]: ...

    @abstractmethod
    def find(self, employee_id: Optional[str] = None, card_no: Optional[int] = None) -> Optional[Employee]: ...

    @abstractmethod
    def create(self, data: EmployeeCreate) -> Employee: ...

    @abstractmethod
    def update(self, employee_uid: int, data: EmployeeUpdate) -> Optional[Employee]: ...

    @abstractmethod
    def soft_delete(self, employee_uid: int) -> bool: ...

    @abstractmethod
    def exists_by_employee_id(self, employee_id: str, exclude_uid: Optional[int] = None) -> bool: ...
