from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Index
from sqlalchemy.orm import relationship
from app.config.database import Base


class AttendanceLog(Base):
    __tablename__ = "attendance_logs"
    __table_args__ = (
        Index("idx_attendance_logs_punch_time", "punch_time"),
        Index("idx_attendance_logs_employee_punch", "employee_id", "punch_time"),
    )

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, ForeignKey("employees.uid", ondelete="SET NULL"))
    unrecognized_biometric = Column(String(255))
    device_id = Column(Integer, ForeignKey("biometric_devices.id", ondelete="SET NULL"))
    punch_time = Column(DateTime, nullable=False)

    employee = relationship("Employee", foreign_keys=[employee_id], lazy="joined")
    device = relationship("BiometricDevice", foreign_keys=[device_id], lazy="joined")
