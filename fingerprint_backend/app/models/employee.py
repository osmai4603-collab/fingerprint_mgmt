from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from app.config.database import Base
from datetime import datetime


class Employee(Base):
    __tablename__ = "employees"

    uid = Column(Integer, primary_key=True, index=True)
    employee_id = Column(String(100), nullable=False, unique=True)
    name = Column(String(255), nullable=False)
    role = Column(String(20), nullable=False, default="user")
    password = Column(String(255))
    group_id = Column(String(100))
    card_no = Column(Integer)
    default_shift_id = Column(Integer, ForeignKey("shifts.id", ondelete="SET NULL"))
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    shift = relationship("Shift", foreign_keys=[default_shift_id], lazy="joined")
    app_user = relationship("AppUser", back_populates="employee", uselist=False, lazy="joined")
    fingerprints = relationship("EmployeeFingerprint", back_populates="employee", lazy="joined")
