from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from app.config.database import get_db
from app.models.attendance import AttendanceLog
from app.models.employee import Employee
from app.schemas.attendance import AttendanceLogResponse
from app.repositories import get_attendance_log_repo, get_employee_repo
from app.repositories.interfaces.attendance_log_repository import AttendanceLogRepository
from app.repositories.interfaces.employee_repository import EmployeeRepository
from app.middleware.auth import get_current_user
from app.models.app_user import AppUser
from app.utils.logger import Logger, LogTimer
from app.services.attendance_calculator import calculate_attendance_times
from datetime import datetime, timedelta, time
from pydantic import BaseModel

class CreateAttendanceLogRequest(BaseModel):
    employee_id: int
    device_id: int
    punch_time: datetime
    unrecognized_biometric: Optional[str] = None

class ManualPunchRequest(BaseModel):
    employee_id: int
    punch_time: datetime
    device_id: Optional[int] = None

router = APIRouter(prefix="/api/attendance", tags=["Attendance"])


def _parse_date(s: str) -> datetime:
    for fmt in ("%Y-%m-%d", "%d-%m-%Y"):
        try:
            return datetime.strptime(s, fmt)
        except ValueError:
            pass
    raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD or DD-MM-YYYY")


@router.get("/logs")
def get_logs(
    employee_id: Optional[int] = Query(None),
    device_id: Optional[int] = Query(None),
    date: Optional[str] = Query(None, description="Format: YYYY-MM-DD"),
    from_date: Optional[str] = Query(None, alias="from", description="Format: YYYY-MM-DD"),
    to_date: Optional[str] = Query(None, alias="to", description="Format: YYYY-MM-DD"),
    calculate: bool = Query(False, description="حساب وقت الحضور والانصراف بدلاً من البصمات الخام"),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),  # Temporary: calculate mode still needs Session
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
):
    with LogTimer("GET /api/attendance/logs"):
        if calculate and employee_id is not None and from_date is not None and to_date is not None:
            f_date = _parse_date(from_date).date()
            t_date = _parse_date(to_date).date()
            if f_date > t_date:
                f_date, t_date = t_date, f_date
            return calculate_attendance_times(db, employee_id, f_date, t_date)

        from_dt = None
        to_dt = None

        if date is not None:
            target_date = _parse_date(date).date()
            from_dt = datetime.combine(target_date, time.min)
            to_dt = datetime.combine(target_date, time.max)
        else:
            if from_date is not None:
                from_dt = datetime.combine(_parse_date(from_date).date(), time.min)
            if to_date is not None:
                to_dt = datetime.combine(_parse_date(to_date).date(), time.max)

        logs = repo.get_filtered(
            employee_id=employee_id,
            device_id=device_id,
            from_date=from_dt,
            to_date=to_dt,
            limit=limit,
            offset=offset,
        )
        Logger.exit("GET /api/attendance/logs", len(logs))
        return logs


@router.post("/logs", response_model=AttendanceLogResponse, status_code=201)
def create_log(
    request: CreateAttendanceLogRequest,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("POST /api/attendance/logs"):
        employee = emp_repo.get_by_uid(request.employee_id)
        if not employee:
            raise HTTPException(status_code=404, detail="Employee not found")

        duplicate = repo.get_duplicate(request.employee_id, request.punch_time)
        if duplicate:
            Logger.exit("POST /api/attendance/logs", "duplicate")
            return duplicate

        log = repo.create(
            employee_id=request.employee_id,
            device_id=request.device_id,
            punch_time=request.punch_time,
            unrecognized_biometric=request.unrecognized_biometric,
        )
        Logger.exit("POST /api/attendance/logs", log.id)
        return log


@router.get("/unrecognized", response_model=list[AttendanceLogResponse])
def get_unrecognized_logs(
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    return repo.get_unrecognized()


@router.put("/logs/{log_id}/link", response_model=AttendanceLogResponse)
def link_unrecognized_log(
    log_id: int,
    employee_id: int = Query(...),
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    db: Session = Depends(get_db),  # Temporary: use case needs Session
    current_user: AppUser = Depends(get_current_user),
):
    log = repo.get_by_id(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Log not found")

    employee = emp_repo.get_by_uid(employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    updated = repo.update(log_id, {"employee_id": employee_id})

    from app.usecases.attendance import ProcessAttendanceLogUseCase
    try:
        processor = ProcessAttendanceLogUseCase(db)
        processor.execute(updated)
    except Exception as e:
        print(f"Error processing linked log: {e}")

    return updated


@router.post("/manual-punch", response_model=AttendanceLogResponse)
def add_manual_punch(
    request: ManualPunchRequest,
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    db: Session = Depends(get_db),  # Temporary: use case needs Session
    current_user: AppUser = Depends(get_current_user),
):
    employee = emp_repo.get_by_uid(request.employee_id)
    if not employee:
        raise HTTPException(status_code=404, detail="Employee not found")

    duplicate = repo.get_duplicate(request.employee_id, request.punch_time)
    if duplicate:
        raise HTTPException(
            status_code=400,
            detail=f"Duplicate punch detected within 5 minutes at {duplicate.punch_time.strftime('%Y-%m-%d %H:%M:%S')}"
        )

    log = repo.create(
        employee_id=request.employee_id,
        device_id=request.device_id,
        punch_time=request.punch_time,
    )

    from app.usecases.attendance import ProcessAttendanceLogUseCase
    try:
        processor = ProcessAttendanceLogUseCase(db)
        processor.execute(log)
    except Exception as e:
        print(f"Error processing manual punch: {e}")

    return log


@router.get("/logs/{log_id}", response_model=AttendanceLogResponse)
def get_log(
    log_id: int,
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    log = repo.get_by_id(log_id)
    if not log:
        raise HTTPException(status_code=404, detail="Attendance log not found")
    return log


class UpdateAttendanceLogRequest(BaseModel):
    employee_id: Optional[int] = None
    device_id: Optional[int] = None
    punch_time: Optional[datetime] = None
    unrecognized_biometric: Optional[str] = None


@router.put("/logs/{log_id}", response_model=AttendanceLogResponse)
def update_log(
    log_id: int,
    request: UpdateAttendanceLogRequest,
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    updated = repo.update(log_id, request.model_dump(exclude_unset=True))
    if not updated:
        raise HTTPException(status_code=404, detail="Attendance log not found")
    return updated


@router.delete("/logs/{log_id}")
def delete_log(
    log_id: int,
    repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not repo.delete(log_id):
        raise HTTPException(status_code=404, detail="Attendance log not found")
    return {"message": "Attendance log deleted successfully"}
