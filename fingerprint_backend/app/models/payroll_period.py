from sqlalchemy import Column, Integer, Date, Boolean, UniqueConstraint
from app.config.database import Base


class PayrollPeriod(Base):
    __tablename__ = "payroll_periods"
    __table_args__ = (
        UniqueConstraint("start_date", "end_date", name="uq_payroll_periods_dates"),
    )

    id = Column(Integer, primary_key=True, index=True)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    is_closed = Column(Boolean, nullable=False, default=False)
