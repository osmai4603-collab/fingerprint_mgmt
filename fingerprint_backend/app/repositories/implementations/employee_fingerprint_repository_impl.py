from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.employee_fingerprint import EmployeeFingerprint
from app.repositories.interfaces.employee_fingerprint_repository import EmployeeFingerprintRepository


class EmployeeFingerprintRepositoryImpl(EmployeeFingerprintRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_employee(self, employee_id: int) -> list[EmployeeFingerprint]:
        return self.db.query(EmployeeFingerprint).filter(
            EmployeeFingerprint.employee_id == employee_id
        ).all()

    def get_by_id(self, fp_id: int) -> Optional[EmployeeFingerprint]:
        return self.db.query(EmployeeFingerprint).filter(EmployeeFingerprint.id == fp_id).first()

    def get_by_employee_and_index(self, employee_id: int, finger_index: int) -> Optional[EmployeeFingerprint]:
        return self.db.query(EmployeeFingerprint).filter(
            EmployeeFingerprint.employee_id == employee_id,
            EmployeeFingerprint.finger_index == finger_index,
        ).first()

    def get_by_biometric(self, biometric: str) -> Optional[EmployeeFingerprint]:
        return self.db.query(EmployeeFingerprint).filter(
            EmployeeFingerprint.biometric == biometric
        ).first()

    def create(self, employee_id: int, biometric: str, finger_index: int) -> EmployeeFingerprint:
        fp = EmployeeFingerprint(
            employee_id=employee_id,
            biometric=biometric,
            finger_index=finger_index,
        )
        self.db.add(fp)
        self.db.commit()
        self.db.refresh(fp)
        return fp

    def delete(self, fp_id: int) -> bool:
        fp = self.get_by_id(fp_id)
        if not fp:
            return False
        self.db.delete(fp)
        self.db.commit()
        return True

    def count_by_employee(self, employee_id: int) -> int:
        return self.db.query(func.count(EmployeeFingerprint.id)).filter(
            EmployeeFingerprint.employee_id == employee_id
        ).scalar() or 0
