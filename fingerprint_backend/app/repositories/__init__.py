from fastapi import Depends
from sqlalchemy.orm import Session
from app.config.database import get_db

from app.repositories.interfaces.shift_repository import ShiftRepository
from app.repositories.implementations.shift_repository_impl import ShiftRepositoryImpl
from app.repositories.interfaces.employee_repository import EmployeeRepository
from app.repositories.implementations.employee_repository_impl import EmployeeRepositoryImpl
from app.repositories.interfaces.biometric_device_repository import BiometricDeviceRepository
from app.repositories.implementations.biometric_device_repository_impl import BiometricDeviceRepositoryImpl
from app.repositories.interfaces.app_user_repository import AppUserRepository
from app.repositories.implementations.app_user_repository_impl import AppUserRepositoryImpl
from app.repositories.interfaces.employee_fingerprint_repository import EmployeeFingerprintRepository
from app.repositories.implementations.employee_fingerprint_repository_impl import EmployeeFingerprintRepositoryImpl
from app.repositories.interfaces.attendance_log_repository import AttendanceLogRepository
from app.repositories.implementations.attendance_log_repository_impl import AttendanceLogRepositoryImpl
from app.repositories.interfaces.attendance_record_repository import AttendanceRecordRepository
from app.repositories.implementations.attendance_record_repository_impl import AttendanceRecordRepositoryImpl
from app.repositories.interfaces.payroll_period_repository import PayrollPeriodRepository
from app.repositories.implementations.payroll_period_repository_impl import PayrollPeriodRepositoryImpl


def get_shift_repo(db: Session = Depends(get_db)) -> ShiftRepository:
    return ShiftRepositoryImpl(db)


def get_employee_repo(db: Session = Depends(get_db)) -> EmployeeRepository:
    return EmployeeRepositoryImpl(db)


def get_device_repo(db: Session = Depends(get_db)) -> BiometricDeviceRepository:
    return BiometricDeviceRepositoryImpl(db)


def get_app_user_repo(db: Session = Depends(get_db)) -> AppUserRepository:
    return AppUserRepositoryImpl(db)


def get_fingerprint_repo(db: Session = Depends(get_db)) -> EmployeeFingerprintRepository:
    return EmployeeFingerprintRepositoryImpl(db)


def get_attendance_log_repo(db: Session = Depends(get_db)) -> AttendanceLogRepository:
    return AttendanceLogRepositoryImpl(db)


def get_attendance_record_repo(db: Session = Depends(get_db)) -> AttendanceRecordRepository:
    return AttendanceRecordRepositoryImpl(db)


def get_payroll_period_repo(db: Session = Depends(get_db)) -> PayrollPeriodRepository:
    return PayrollPeriodRepositoryImpl(db)
