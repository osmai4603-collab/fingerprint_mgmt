from typing import Optional
from datetime import date
from sqlalchemy.orm import Session
from app.models.payroll_period import PayrollPeriod
from app.repositories.interfaces.payroll_period_repository import PayrollPeriodRepository


class PayrollPeriodRepositoryImpl(PayrollPeriodRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, period_id: int) -> Optional[PayrollPeriod]:
        return self.db.query(PayrollPeriod).filter(PayrollPeriod.id == period_id).first()

    def get_current_open(self) -> Optional[PayrollPeriod]:
        return self.db.query(PayrollPeriod).filter(
            PayrollPeriod.is_closed == False,
        ).order_by(PayrollPeriod.id.desc()).first()

    def get_by_date(self, punch_date: date) -> Optional[PayrollPeriod]:
        return self.db.query(PayrollPeriod).filter(
            PayrollPeriod.start_date <= punch_date,
            PayrollPeriod.end_date >= punch_date,
        ).first()
