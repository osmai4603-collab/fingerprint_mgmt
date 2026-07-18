from datetime import datetime
from sqlalchemy.orm import Session
from app.models.employee import Employee
from app.models.shift import Shift
from app.models.attendance import AttendanceLog
from app.models.attendance_record import AttendanceRecord
from app.models.payroll_period import PayrollPeriod
from app.utils.logger import Logger, LogTimer
from app.services.calculate_time import CalculateTime, AttendanceStatus


class ProcessAttendanceLogUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, log: AttendanceLog) -> AttendanceRecord:
        with LogTimer("ProcessAttendanceLogUseCase"):
            if not log.employee_id:
                raise ValueError("Attendance log has no employee_id")

            employee = self.db.query(Employee).filter(Employee.uid == log.employee_id).first()
            if not employee:
                raise ValueError(f"Employee {log.employee_id} not found")

            shift = None
            if employee.default_shift_id:
                shift = self.db.query(Shift).filter(Shift.id == employee.default_shift_id).first()
                if shift:
                    Logger.enter("Shift_Loaded", {"shift_id": shift.id})

            record_date = log.punch_time.strftime("%Y-%m-%d")
            existing = self.db.query(AttendanceRecord).filter(
                AttendanceRecord.employee_id == employee.uid,
                AttendanceRecord.record_date == record_date,
            ).first()

            if existing:
                record = existing
                is_first_punch = False
            else:
                punch_date = log.punch_time.date()
                period = self.db.query(PayrollPeriod).filter(
                    PayrollPeriod.start_date <= punch_date,
                    PayrollPeriod.end_date >= punch_date,
                ).first()
                if not period:
                    raise ValueError(f"No payroll period found for date {record_date}")
                record = AttendanceRecord(
                    employee_id=employee.uid,
                    payroll_period_id=period.id,
                    record_date=record_date,
                    total_hours=0,
                    lateness_mins=0,
                    overtime_mins=0,
                )
                self.db.add(record)
                is_first_punch = True
                Logger.enter("Record_Created", {"employee_id": employee.uid, "date": record_date})

            if shift and is_first_punch:
                punch_date = log.punch_time.date()
                status = CalculateTime.get_attendance_status(
                    before_shift_start_time=shift.before_start_time,
                    official_shift_start_time=shift.start_time,
                    after_shift_start_time=shift.after_start_time,
                    max_attendance_time=shift.max_attendance_time,
                    date_val=punch_date,
                    timestamp=log.punch_time,
                )
                if status == AttendanceStatus.LATE:
                    shift_start = CalculateTime._merge_time_with_date(
                        shift.start_time, punch_date,
                        is_night_shift=shift.is_night_shift,
                        shift_start_hour=shift.start_time.hour,
                    )
                    diff_min = int((log.punch_time - shift_start).total_seconds() / 60)
                    if diff_min > 0:
                        record.lateness_mins = diff_min
                        Logger.enter("Lateness_Calculated", {"mins": diff_min})

            if shift and not is_first_punch:
                punch_date = log.punch_time.date()
                overtime = CalculateTime.calculate_excess_hours(
                    log.punch_time, punch_date, shift.after_end_time, shift,
                )
                if overtime.total_seconds() > 0:
                    record.overtime_mins = int(overtime.total_seconds() / 60)
                    Logger.enter("Overtime_Calculated", {"mins": record.overtime_mins})

            self.db.commit()
            self.db.refresh(record)
            return record


class GenerateAttendanceReportUseCase:
    def __init__(self, db: Session):
        self.db = db

    def execute(self, employee_id: int, start_date: str, end_date: str) -> dict:
        with LogTimer("GenerateAttendanceReportUseCase"):
            employee = self.db.query(Employee).filter(Employee.uid == employee_id).first()
            if not employee:
                raise ValueError(f"Employee {employee_id} not found")

            records = self.db.query(AttendanceRecord).filter(
                AttendanceRecord.employee_id == employee_id,
                AttendanceRecord.record_date >= start_date,
                AttendanceRecord.record_date <= end_date,
            ).all()

            total_days = 0
            present_days = 0
            absent_days = 0
            total_hours = 0.0
            total_lateness = 0
            total_overtime = 0

            for record in records:
                total_days += 1
                if record.total_hours > 0:
                    present_days += 1
                    total_hours += float(str(record.total_hours))
                else:
                    absent_days += 1
                total_lateness += record.lateness_mins
                total_overtime += record.overtime_mins

            result = {
                "employee_id": employee_id,
                "employee_name": employee.name,
                "start_date": start_date,
                "end_date": end_date,
                "total_days": total_days,
                "present_days": present_days,
                "absent_days": absent_days,
                "total_hours": round(total_hours, 2),
                "total_lateness_mins": total_lateness,
                "total_overtime_mins": total_overtime,
            }
            Logger.exit("GenerateAttendanceReportUseCase", len(records))
            return result
