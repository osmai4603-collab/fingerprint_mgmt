import csv
import io
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.models.employee import Employee
from app.models.attendance_record import AttendanceRecord
from app.schemas.employee import (
    EmployeeCreate,
    EmployeeUpdate,
    EmployeeResponse,
    EmployeeWithShiftResponse,
    EmployeeSummaryResponse,
    EmployeeFullResponse,
    EmployeeShiftInfo,
    EmployeeFingerprintInfo,
    EmployeeAppUserInfo,
    FingerprintResponse,
    FingerprintCreate,
    FingerprintSearchRequest,
    FingerprintSearchResponse,
    CsvImportRequest,
)
from app.repositories import (
    get_employee_repo,
    get_fingerprint_repo,
    get_attendance_record_repo,
    get_payroll_period_repo,
    get_shift_repo,
)
from app.repositories.interfaces.employee_repository import EmployeeRepository
from app.repositories.interfaces.employee_fingerprint_repository import EmployeeFingerprintRepository
from app.repositories.interfaces.attendance_record_repository import AttendanceRecordRepository
from app.repositories.interfaces.payroll_period_repository import PayrollPeriodRepository
from app.repositories.interfaces.shift_repository import ShiftRepository
from app.utils.password_utils import PasswordUtils
from app.middleware.auth import get_current_user
from app.models.app_user import AppUser

router = APIRouter(prefix="/api/employees", tags=["Employees"])


@router.get("/", response_model=list[EmployeeFullResponse])
def get_employees(
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employees = emp_repo.get_all(is_active=True)
    result = []
    for emp in employees:
        item = EmployeeFullResponse(
            uid=emp.uid,
            employee_id=emp.employee_id,
            name=emp.name,
            role=emp.role,
            group_id=emp.group_id,
            card_no=emp.card_no,
            default_shift_id=emp.default_shift_id,
            is_active=emp.is_active,
            created_at=emp.created_at,
            updated_at=emp.updated_at,
        )
        if emp.shift:
            item.shift = EmployeeShiftInfo(
                id=emp.shift.id,
                name=emp.shift.name,
                start_time=str(emp.shift.start_time),
                end_time=str(emp.shift.end_time),
            )
        if emp.fingerprints:
            item.fingerprints = [
                EmployeeFingerprintInfo(id=fp.id, biometric=fp.biometric, finger_index=fp.finger_index)
                for fp in emp.fingerprints
            ]
        if emp.app_user:
            item.app_user = EmployeeAppUserInfo(
                id=emp.app_user.id,
                username=emp.app_user.username,
                role=emp.app_user.role,
                is_active=emp.app_user.is_active,
            )
        result.append(item)
    return result


@router.get("/find", response_model=Optional[EmployeeResponse])
def find_employee(
    employee_id: Optional[str] = None,
    card_no: Optional[int] = None,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not employee_id and not card_no:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Provide employee_id or card_no",
        )
    employee = emp_repo.find(employee_id=employee_id, card_no=card_no)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    return employee


@router.post("/import-csv", status_code=status.HTTP_200_OK)
def import_employees_csv(
    data: CsvImportRequest,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    db: Session = Depends(get_db),
    current_user: AppUser = Depends(get_current_user),
):
    reader = csv.DictReader(io.StringIO(data.csv_content))
    created = 0
    updated = 0
    errors = []

    for i, row in enumerate(reader, start=1):
        try:
            emp_id = row.get("employee_id", "").strip()
            if not emp_id:
                errors.append(f"Row {i}: missing employee_id")
                continue

            existing = emp_repo.get_by_employee_id(emp_id)
            if existing:
                if row.get("name"):
                    existing.name = row["name"].strip()
                if row.get("role"):
                    existing.role = row["role"].strip()
                if row.get("group_id"):
                    existing.group_id = row["group_id"].strip()
                if row.get("card_no"):
                    existing.card_no = int(row["card_no"].strip())
                if row.get("default_shift_id"):
                    existing.default_shift_id = int(row["default_shift_id"].strip())
                updated += 1
            else:
                employee = Employee(
                    employee_id=emp_id,
                    name=row.get("name", "").strip(),
                    role=row.get("role", "user").strip(),
                    group_id=row.get("group_id", "").strip() or None,
                    card_no=int(row["card_no"].strip()) if row.get("card_no") else None,
                    default_shift_id=int(row["default_shift_id"].strip()) if row.get("default_shift_id") else None,
                )
                db.add(employee)
                created += 1
        except Exception as e:
            errors.append(f"Row {i}: {str(e)}")

    db.commit()
    return {"created": created, "updated": updated, "errors": errors}


@router.post("/search-by-fingerprint", response_model=FingerprintSearchResponse)
def search_by_fingerprint(
    data: FingerprintSearchRequest,
    fp_repo: EmployeeFingerprintRepository = Depends(get_fingerprint_repo),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    fp = fp_repo.get_by_biometric(data.biometric)
    if not fp:
        return FingerprintSearchResponse(matched=False)
    employee = emp_repo.get_by_uid(fp.employee_id)
    if not employee:
        return FingerprintSearchResponse(matched=False)
    return FingerprintSearchResponse(
        matched=True,
        employee_uid=employee.uid,
        employee_name=employee.name,
    )


@router.post("/", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
def create_employee(
    data: EmployeeCreate,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if emp_repo.exists_by_employee_id(data.employee_id):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Employee ID already exists",
        )
    return emp_repo.create(data)


@router.get("/{employee_uid}", response_model=EmployeeResponse)
def get_employee(
    employee_uid: int,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    return employee


@router.get("/{employee_uid}/with-shift", response_model=EmployeeWithShiftResponse)
def get_employee_with_shift(
    employee_uid: int,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    result = EmployeeWithShiftResponse.model_validate(employee)
    if employee.shift:
        result.shift_name = employee.shift.name
        result.shift_start = str(employee.shift.start_time)
        result.shift_end = str(employee.shift.end_time)
    return result


@router.get("/{employee_uid}/summary", response_model=EmployeeSummaryResponse)
def get_employee_summary(
    employee_uid: int,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    payroll_repo: PayrollPeriodRepository = Depends(get_payroll_period_repo),
    att_rec_repo: AttendanceRecordRepository = Depends(get_attendance_record_repo),
    fp_repo: EmployeeFingerprintRepository = Depends(get_fingerprint_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    current_period = payroll_repo.get_current_open()

    if current_period:
        stats = att_rec_repo.get_employee_summary(employee_uid, current_period.id)
    else:
        stats = (0, 0, 0)

    fp_count = fp_repo.count_by_employee(employee_uid)

    return EmployeeSummaryResponse(
        employee_uid=employee.uid,
        employee_id=employee.employee_id,
        name=employee.name,
        total_working_hours=float(stats[0]),
        total_late_mins=int(stats[1]),
        total_overtime_mins=int(stats[2]),
        fingerprint_count=fp_count or 0,
        shift_name=employee.shift.name if employee.shift else None,
    )


@router.get("/{employee_uid}/fingerprints", response_model=list[FingerprintResponse])
def get_fingerprints(
    employee_uid: int,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    fp_repo: EmployeeFingerprintRepository = Depends(get_fingerprint_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    return fp_repo.get_by_employee(employee_uid)


@router.post("/{employee_uid}/fingerprints", response_model=FingerprintResponse, status_code=status.HTTP_201_CREATED)
def add_fingerprint(
    employee_uid: int,
    data: FingerprintCreate,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    fp_repo: EmployeeFingerprintRepository = Depends(get_fingerprint_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    return fp_repo.create(employee_id=employee_uid, biometric=data.biometric, finger_index=data.finger_index)


@router.delete("/{employee_uid}/fingerprints/{fingerprint_id}")
def delete_fingerprint(
    employee_uid: int,
    fingerprint_id: int,
    fp_repo: EmployeeFingerprintRepository = Depends(get_fingerprint_repo),
    current_user: AppUser = Depends(get_current_user),
):
    fp = fp_repo.get_by_id(fingerprint_id)
    if not fp or fp.employee_id != employee_uid:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Fingerprint not found")
    fp_repo.delete(fingerprint_id)
    return {"message": "Fingerprint deleted successfully"}


@router.put("/{employee_uid}", response_model=EmployeeResponse)
def update_employee(
    employee_uid: int,
    data: EmployeeUpdate,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(employee_uid)
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    if data.employee_id and data.employee_id != employee.employee_id:
        if emp_repo.exists_by_employee_id(data.employee_id, exclude_uid=employee_uid):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Employee ID already exists",
            )

    updated = emp_repo.update(employee_uid, data)
    return updated


@router.delete("/{employee_uid}")
def delete_employee(
    employee_uid: int,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not emp_repo.soft_delete(employee_uid):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")
    return {"message": "Employee deactivated successfully"}
