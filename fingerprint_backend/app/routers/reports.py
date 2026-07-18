from fastapi import APIRouter, Depends, Query, HTTPException
from typing import Optional
from datetime import datetime, timedelta, time, date as date_type
from app.models.shift import Shift
from app.schemas.reports import (
    EmployeeFingerprintReportResponse,
    AttendanceSummaryReportResponse,
    DetailedDailyReportResponse,
)
from app.repositories import (
    get_employee_repo,
    get_attendance_log_repo,
    get_shift_repo,
)
from app.repositories.interfaces.employee_repository import EmployeeRepository
from app.repositories.interfaces.attendance_log_repository import AttendanceLogRepository
from app.repositories.interfaces.shift_repository import ShiftRepository
from app.middleware.auth import get_current_user
from app.models.app_user import AppUser
from app.utils.logger import Logger, LogTimer
from app.services.calculate_time import CalculateTime, AttendanceStatus

router = APIRouter(prefix="/api/reports", tags=["Reports"])


def _parse_date(s: str) -> date_type:
    for fmt in ("%Y-%m-%d", "%d-%m-%Y"):
        try:
            return datetime.strptime(s, fmt).date()
        except ValueError:
            pass
    raise HTTPException(
        status_code=400,
        detail="Invalid date format. Use YYYY-MM-DD or DD-MM-YYYY",
    )


def _get_employees(
    emp_repo: EmployeeRepository,
    employee_id: Optional[int] = None,
) -> list:
    employees = emp_repo.get_all(is_active=True)
    if employee_id is not None:
        employees = [e for e in employees if e.uid == employee_id]
    return employees


@router.get("/fingerprint", response_model=list[EmployeeFingerprintReportResponse])
def fingerprint_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/fingerprint"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start

        employees = _get_employees(emp_repo, employee_id)
        report = []
        current = start

        while current <= end:
            day_start = datetime.combine(current, time.min)
            day_end = datetime.combine(current, time.max)

            for emp in employees:
                logs = att_log_repo.get_by_employee_and_time_range(
                    emp.uid, day_start, day_end
                )

                if not logs:
                    continue

                punches = [log.punch_time for log in logs[:6]]
                row = {
                    "employee_id": emp.uid,
                    "employee_name": emp.name,
                    "date": str(current),
                }
                for i in range(6):
                    row[f"punch{i + 1}"] = punches[i] if i < len(punches) else None

                report.append(row)

            current += timedelta(days=1)

        return report


@router.get("/summary", response_model=list[AttendanceSummaryReportResponse])
def summary_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    hourly_rate: float = Query(0, description="الساعة كلفة لخصم الغياب"),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/summary"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start

        employees = _get_employees(emp_repo, employee_id)
        report = []
        current = start

        emp_totals: dict[int, dict] = {}
        for emp in employees:
            shift = None
            if emp.default_shift_id:
                shift = shift_repo.get_by_id(emp.default_shift_id)
            emp_totals[emp.uid] = {
                "name": emp.name,
                "shift": shift,
                "work_hours": 0.0,
                "overtime_hours": 0.0,
                "absence_hours": 0.0,
            }

        while current <= end:
            day_start = datetime.combine(current, time.min)
            day_end = datetime.combine(current, time.max)

            for emp in employees:
                tot = emp_totals[emp.uid]
                shift = tot["shift"]

                query_end = day_end
                if shift and shift.is_night_shift:
                    query_end = datetime.combine(current + timedelta(days=1), time.max)

                logs = att_log_repo.get_by_employee_and_time_range(emp.uid, day_start, query_end)

                timestamps = [log.punch_time for log in logs]
                attendance_time = None
                departure_time = None

                if shift:
                    attendance_time = CalculateTime.find_matching_timestamp(
                        timestamps, current,
                        shift.start_time, shift.max_attendance_time,
                    )
                    departure_time = CalculateTime.find_departure_timestamp(
                        timestamps, current,
                        shift.before_end_time, shift.after_end_time,
                        is_night_shift=shift.is_night_shift,
                        shift_start_hour=shift.start_time.hour,
                    )

                if attendance_time is not None and departure_time is not None and shift:
                    work_td = CalculateTime.calculate_working_hours(
                        attendance_time, departure_time, current, shift,
                    )
                    excess_td = CalculateTime.calculate_excess_hours(
                        departure_time, current, shift.after_end_time, shift,
                    )
                    tot["work_hours"] += work_td.total_seconds() / 3600
                    tot["overtime_hours"] += excess_td.total_seconds() / 3600
                elif shift:
                    absence_td = CalculateTime.calculate_absence_hours(
                        None, None, current, shift,
                    )
                    tot["absence_hours"] += absence_td.total_seconds() / 3600

            current += timedelta(days=1)

        for emp in employees:
            tot = emp_totals[emp.uid]
            deduction = round(tot["absence_hours"] * hourly_rate, 2)
            report.append({
                "employee_id": emp.uid,
                "employee_name": tot["name"],
                "work_hours": round(tot["work_hours"], 2),
                "overtime_hours": round(tot["overtime_hours"], 2),
                "absence_hours": round(tot["absence_hours"], 2),
                "deduction_amount": deduction,
            })

        return report


def _build_detailed_rows(
    att_log_repo: AttendanceLogRepository,
    shift_repo: ShiftRepository,
    emp_repo: EmployeeRepository,
    start: date_type,
    end: date_type,
    employee_id: Optional[int],
    status_filter: Optional[str] = None,
) -> list[dict]:
    employees = _get_employees(emp_repo, employee_id)
    report = []
    current = start

    while current <= end:
        day_start = datetime.combine(current, time.min)
        day_end = datetime.combine(current, time.max)

        for emp in employees:
            shift = None
            shift_name = None
            if emp.default_shift_id:
                shift = shift_repo.get_by_id(emp.default_shift_id)
                if shift:
                    shift_name = shift.name

            query_end = day_end
            if shift and shift.is_night_shift:
                query_end = datetime.combine(current + timedelta(days=1), time.max)

            logs = att_log_repo.get_by_employee_and_time_range(emp.uid, day_start, query_end)

            timestamps = [log.punch_time for log in logs]
            attendance_time = None
            departure_time = None

            if shift:
                attendance_time = CalculateTime.find_matching_timestamp(
                    timestamps, current,
                    shift.before_start_time, shift.max_attendance_time,
                )
                departure_time = CalculateTime.find_departure_timestamp(
                    timestamps, current,
                    shift.before_end_time, shift.after_end_time,
                    is_night_shift=shift.is_night_shift,
                    shift_start_hour=shift.start_time.hour,
                )

            work_hours = 0.0
            overtime_hours = 0.0
            absence_hours = 0.0
            att_status = "---"

            if attendance_time and departure_time and shift:
                work_td = CalculateTime.calculate_working_hours(
                    attendance_time, departure_time, current, shift,
                )
                excess_td = CalculateTime.calculate_excess_hours(
                    departure_time, current, shift.after_end_time, shift,
                )
                absence_td = CalculateTime.calculate_absence_hours(
                    attendance_time, departure_time, current, shift,
                )
                work_hours = round(work_td.total_seconds() / 3600, 2)
                overtime_hours = round(excess_td.total_seconds() / 3600, 2)
                absence_hours = round(absence_td.total_seconds() / 3600, 2)

                status = CalculateTime.get_attendance_status(
                    before_shift_start_time=shift.before_start_time,
                    official_shift_start_time=shift.start_time,
                    after_shift_start_time=shift.after_start_time,
                    max_attendance_time=shift.max_attendance_time,
                    date_val=current,
                    timestamp=attendance_time,
                )
                att_status = status.value
            elif shift:
                absence_td = CalculateTime.calculate_absence_hours(
                    None, None, current, shift,
                )
                absence_hours = round(absence_td.total_seconds() / 3600, 2)
                if absence_hours > 0:
                    att_status = "غائب"

            if status_filter == "present" and work_hours == 0:
                continue
            if status_filter == "absent" and work_hours > 0:
                continue
            if status_filter == "late" and att_status != AttendanceStatus.LATE.value:
                continue

            report.append({
                "employee_id": emp.uid,
                "employee_name": emp.name,
                "date": str(current),
                "shift_name": shift_name,
                "attendance_time": attendance_time,
                "departure_time": departure_time,
                "work_hours": work_hours,
                "overtime_hours": overtime_hours,
                "absence_hours": absence_hours,
                "attendance_status": att_status,
            })

        current += timedelta(days=1)

    return report


@router.get("/detailed", response_model=list[DetailedDailyReportResponse])
def detailed_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/detailed"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start
        return _build_detailed_rows(
            att_log_repo, shift_repo, emp_repo, start, end, employee_id
        )


@router.get("/attendance-only", response_model=list[DetailedDailyReportResponse])
def attendance_only_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/attendance-only"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start
        rows = _build_detailed_rows(
            att_log_repo, shift_repo, emp_repo, start, end, employee_id,
            status_filter="present",
        )
        for row in rows:
            row["overtime_hours"] = 0.0
        return rows


@router.get("/absence-only", response_model=list[DetailedDailyReportResponse])
def absence_only_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/absence-only"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start
        rows = _build_detailed_rows(
            att_log_repo, shift_repo, emp_repo, start, end, employee_id,
            status_filter="absent",
        )
        for row in rows:
            row["work_hours"] = 0.0
            row["overtime_hours"] = 0.0
        return rows


@router.get("/late", response_model=list[DetailedDailyReportResponse])
def late_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/late"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start
        return _build_detailed_rows(
            att_log_repo, shift_repo, emp_repo, start, end, employee_id,
            status_filter="late",
        )


@router.get("/absence-deductions", response_model=list[DetailedDailyReportResponse])
def absence_deductions_report(
    from_date: str = Query(..., alias="from", description="Format: YYYY-MM-DD"),
    to_date: str = Query(..., alias="to", description="Format: YYYY-MM-DD"),
    employee_id: Optional[int] = Query(None),
    hourly_rate: float = Query(0, description="قيمة الساعة للخصم"),
    emp_repo: EmployeeRepository = Depends(get_employee_repo),
    att_log_repo: AttendanceLogRepository = Depends(get_attendance_log_repo),
    shift_repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    with LogTimer("GET /api/reports/absence-deductions"):
        start = _parse_date(from_date)
        end = _parse_date(to_date)
        if start > end:
            start, end = end, start
        rows = _build_detailed_rows(
            att_log_repo, shift_repo, emp_repo, start, end, employee_id,
            status_filter="absent",
        )
        for row in rows:
            row["work_hours"] = 0.0
            row["overtime_hours"] = 0.0
            row["absence_hours"] = round(row.get("absence_hours", 0), 2)
            row["attendance_status"] = "غائب (خصم)"
        return rows
