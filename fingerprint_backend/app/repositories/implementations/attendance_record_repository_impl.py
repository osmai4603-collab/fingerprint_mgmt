from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.attendance_record import AttendanceRecord
from app.repositories.interfaces.attendance_record_repository import AttendanceRecordRepository


class AttendanceRecordRepositoryImpl(AttendanceRecordRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, record_id: int) -> Optional[AttendanceRecord]:
        return self.db.query(AttendanceRecord).filter(AttendanceRecord.id == record_id).first()

    def get_by_employee_and_date(self, employee_id: int, record_date: str) -> Optional[AttendanceRecord]:
        return self.db.query(AttendanceRecord).filter(
            AttendanceRecord.employee_id == employee_id,
            AttendanceRecord.record_date == record_date,
        ).first()

    def get_by_employee_and_period(self, employee_id: int, period_id: int) -> list[AttendanceRecord]:
        return self.db.query(AttendanceRecord).filter(
            AttendanceRecord.employee_id == employee_id,
            AttendanceRecord.payroll_period_id == period_id,
        ).all()

    def get_by_employee_and_date_range(self, employee_id: int, start_date: str, end_date: str) -> list[AttendanceRecord]:
        return self.db.query(AttendanceRecord).filter(
            AttendanceRecord.employee_id == employee_id,
            AttendanceRecord.record_date >= start_date,
            AttendanceRecord.record_date <= end_date,
        ).all()

    def get_employee_summary(self, employee_id: int, period_id: int) -> tuple:
        query = self.db.query(AttendanceRecord).filter(
            AttendanceRecord.employee_id == employee_id,
            AttendanceRecord.payroll_period_id == period_id,
        )
        return query.with_entities(
            func.coalesce(func.sum(AttendanceRecord.total_hours), 0),
            func.coalesce(func.sum(AttendanceRecord.lateness_mins), 0),
            func.coalesce(func.sum(AttendanceRecord.overtime_mins), 0),
        ).first()

    def create(self, employee_id: int, payroll_period_id: int, record_date: str) -> AttendanceRecord:
        record = AttendanceRecord(
            employee_id=employee_id,
            payroll_period_id=payroll_period_id,
            record_date=record_date,
            total_hours=0,
            lateness_mins=0,
            overtime_mins=0,
        )
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record

    def update(self, record_id: int, data: dict) -> Optional[AttendanceRecord]:
        record = self.get_by_id(record_id)
        if not record:
            return None
        for field, value in data.items():
            setattr(record, field, value)
        self.db.commit()
        self.db.refresh(record)
        return record
