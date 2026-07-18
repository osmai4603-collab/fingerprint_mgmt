from typing import Optional
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from app.models.attendance import AttendanceLog
from app.repositories.interfaces.attendance_log_repository import AttendanceLogRepository


class AttendanceLogRepositoryImpl(AttendanceLogRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, log_id: int) -> Optional[AttendanceLog]:
        return self.db.query(AttendanceLog).filter(AttendanceLog.id == log_id).first()

    def get_filtered(
        self,
        employee_id: Optional[int] = None,
        device_id: Optional[int] = None,
        from_date: Optional[datetime] = None,
        to_date: Optional[datetime] = None,
        limit: int = 100,
        offset: int = 0,
    ) -> list[AttendanceLog]:
        query = self.db.query(AttendanceLog)
        if employee_id is not None:
            query = query.filter(AttendanceLog.employee_id == employee_id)
        if device_id is not None:
            query = query.filter(AttendanceLog.device_id == device_id)
        if from_date is not None:
            query = query.filter(AttendanceLog.punch_time >= from_date)
        if to_date is not None:
            query = query.filter(AttendanceLog.punch_time <= to_date)
        return query.order_by(AttendanceLog.punch_time.desc()).offset(offset).limit(limit).all()

    def get_by_employee_and_time_range(
        self,
        employee_id: int,
        start: datetime,
        end: datetime,
    ) -> list[AttendanceLog]:
        return self.db.query(AttendanceLog).filter(
            AttendanceLog.employee_id == employee_id,
            AttendanceLog.punch_time >= start,
            AttendanceLog.punch_time <= end,
        ).order_by(AttendanceLog.punch_time.asc()).all()

    def get_unrecognized(self) -> list[AttendanceLog]:
        return self.db.query(AttendanceLog).filter(
            AttendanceLog.employee_id.is_(None)
        ).order_by(AttendanceLog.punch_time.desc()).all()

    def get_duplicate(self, employee_id: int, punch_time: datetime, threshold_minutes: int = 5) -> Optional[AttendanceLog]:
        threshold = timedelta(minutes=threshold_minutes)
        start_check = punch_time - threshold
        end_check = punch_time + threshold
        return self.db.query(AttendanceLog).filter(
            AttendanceLog.employee_id == employee_id,
            AttendanceLog.punch_time >= start_check,
            AttendanceLog.punch_time <= end_check,
        ).first()

    def create(self, employee_id: Optional[int], device_id: Optional[int], punch_time: datetime, unrecognized_biometric: Optional[str] = None) -> AttendanceLog:
        log = AttendanceLog(
            employee_id=employee_id,
            device_id=device_id,
            punch_time=punch_time,
            unrecognized_biometric=unrecognized_biometric,
        )
        self.db.add(log)
        self.db.commit()
        self.db.refresh(log)
        return log

    def update(self, log_id: int, data: dict) -> Optional[AttendanceLog]:
        log = self.get_by_id(log_id)
        if not log:
            return None
        for field, value in data.items():
            setattr(log, field, value)
        self.db.commit()
        self.db.refresh(log)
        return log

    def delete(self, log_id: int) -> bool:
        log = self.get_by_id(log_id)
        if not log:
            return False
        self.db.delete(log)
        self.db.commit()
        return True
