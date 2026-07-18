from abc import ABC, abstractmethod
from typing import Optional
from app.models.employee_fingerprint import EmployeeFingerprint


class EmployeeFingerprintRepository(ABC):
    @abstractmethod
    def get_by_employee(self, employee_id: int) -> list[EmployeeFingerprint]: ...

    @abstractmethod
    def get_by_id(self, fp_id: int) -> Optional[EmployeeFingerprint]: ...

    @abstractmethod
    def get_by_employee_and_index(self, employee_id: int, finger_index: int) -> Optional[EmployeeFingerprint]: ...

    @abstractmethod
    def get_by_biometric(self, biometric: str) -> Optional[EmployeeFingerprint]: ...

    @abstractmethod
    def create(self, employee_id: int, biometric: str, finger_index: int) -> EmployeeFingerprint: ...

    @abstractmethod
    def delete(self, fp_id: int) -> bool: ...

    @abstractmethod
    def count_by_employee(self, employee_id: int) -> int: ...
