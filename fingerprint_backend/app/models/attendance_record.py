from sqlalchemy import Column, Integer, String, Date, Numeric, Boolean, DateTime, ForeignKey, Index, UniqueConstraint
from sqlalchemy.orm import relationship
from app.config.database import Base
from datetime import datetime


class AttendanceRecord(Base):
    __tablename__ = "attendance_records"
    __table_args__ = (
        UniqueConstraint("employee_id", "record_date", name="uq_attendance_records_emp_date"),
        Index("idx_attendance_records_date", "record_date"),
        Index("idx_attendance_records_payroll", "payroll_period_id"),
    )

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, ForeignKey("employees.uid", ondelete="CASCADE"), nullable=False)
    payroll_period_id = Column(Integer, ForeignKey("payroll_periods.id", ondelete="RESTRICT"), nullable=False)
    record_date = Column(Date, nullable=False)
    total_hours = Column(Numeric(5, 2), nullable=False, default=0)
    lateness_mins = Column(Integer, nullable=False, default=0)
    overtime_mins = Column(Integer, nullable=False, default=0)
    is_locked = Column(Boolean, nullable=False, default=False)
    flags = Column(String(255))
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    employee = relationship("Employee", foreign_keys=[employee_id], lazy="joined")
    payroll_period = relationship("PayrollPeriod", foreign_keys=[payroll_period_id], lazy="joined")
