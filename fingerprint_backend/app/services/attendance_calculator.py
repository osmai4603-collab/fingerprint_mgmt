from datetime import datetime, time, date as date_type, timedelta
from typing import Optional
from sqlalchemy.orm import Session


def calculate_attendance_times(
    db: Session,
    employee_uid: int,
    from_date: date_type,
    to_date: date_type,
) -> list[dict]:
    """
    تحسب وقت الحضور والانصراف لموظف في نطاق تاريخي.

    الآلية:
    1. جلب جميع بصمات الموظف في النطاق مرتبة تصاعدياً
    2. جلب الوردية الخاصة بالموظف
    3. لكل تاريخ:
       a. تحديد الوردية الليلية بـ start_time > end_time
       b. تحويل before_start_time + التاريخ → datetime → ثواني
       c. تحويل after_end_time + التاريخ → datetime → ثواني (+1 day إن كانت ليلية)
       d. تحويل كل بصمة → ثواني
       e. تصفية: attendance_time ∈ [before_start, after_end)
       f. وقت الحضور: أول بصمة ∈ [before_start, max_attendance)
       g. وقت الانصراف: أول بصمة ∈ [before_end, after_end]
    """
    from app.models.attendance import AttendanceLog
    from app.models.employee import Employee
    from app.models.shift import Shift

    employee = db.query(Employee).filter(Employee.uid == employee_uid).first()
    if not employee or not employee.default_shift_id:
        return []

    shift = db.query(Shift).filter(Shift.id == employee.default_shift_id).first()
    if not shift:
        return []

    is_night = shift.start_time > shift.end_time

    def _merge(t: time, d: date_type, add_day: bool = False) -> datetime:
        dt = datetime(d.year, d.month, d.day, t.hour, t.minute, t.second)
        if add_day:
            dt += timedelta(days=1)
        return dt

    def _needs_next_day(t: time) -> bool:
        return t.hour < shift.start_time.hour

    all_logs = (
        db.query(AttendanceLog)
        .filter(
            AttendanceLog.employee_id == employee_uid,
            AttendanceLog.punch_time >= _merge(shift.before_start_time, from_date),
            AttendanceLog.punch_time <= _merge(shift.after_end_time, to_date if is_night == False else to_date + timedelta(days=1)),
        )
        .order_by(AttendanceLog.punch_time.asc())
        .all()
    )

    report = []
    current = from_date

    while current <= to_date:
        day_start = datetime.combine(current, time.min)
        day_end = datetime.combine(current, time.max)
        if is_night:
            day_end = datetime.combine(current + timedelta(days=1), time.max)
        day_logs = [l for l in all_logs if day_start <= l.punch_time <= day_end]

        before_start = _merge(shift.before_start_time, current)
        before_start_sec = before_start.timestamp()

        after_end = _merge(shift.after_end_time, current, add_day=is_night or _needs_next_day(shift.after_end_time))
        after_end_sec = after_end.timestamp()

        max_att = _merge(shift.max_attendance_time, current, add_day=is_night or _needs_next_day(shift.max_attendance_time))
        max_att_sec = max_att.timestamp()

        before_end = _merge(shift.before_end_time, current, add_day=is_night or _needs_next_day(shift.before_end_time))
        before_end_sec = before_end.timestamp()

        attendance_time: Optional[datetime] = None
        departure_time: Optional[datetime] = None

        # وقت الحضور: أول بصمة في [before_start, max_attendance) — ترتيب تصاعدي
        for log in day_logs:
            log_sec = log.punch_time.timestamp()
            if not (before_start_sec <= log_sec < after_end_sec):
                continue
            if attendance_time is None and before_start_sec <= log_sec < max_att_sec:
                attendance_time = log.punch_time
                break

        # وقت الانصراف: أول بصمة في [before_end, after_end] — ترتيب تنازلي (آخر بصمة)
        for log in reversed(day_logs):
            log_sec = log.punch_time.timestamp()
            if not (before_start_sec <= log_sec < after_end_sec):
                continue
            if departure_time is None and before_end_sec <= log_sec <= after_end_sec:
                departure_time = log.punch_time
                break

        report.append({
            "employee_id": employee_uid,
            "employee_name": employee.name,
            "date": str(current),
            "attendance_time": attendance_time,
            "departure_time": departure_time,
        })

        current += timedelta(days=1)

    return report
