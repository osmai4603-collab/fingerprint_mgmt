from sqlalchemy import Column, Integer, String, Text, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from app.config.database import Base


class EmployeeFingerprint(Base):
    __tablename__ = "employee_fingerprints"
    __table_args__ = (
        UniqueConstraint("employee_id", "finger_index", name="uq_emp_fingerprint"),
    )

    id = Column(Integer, primary_key=True, index=True)
    employee_id = Column(Integer, ForeignKey("employees.uid", ondelete="CASCADE"), nullable=False)
    biometric = Column(Text, nullable=False)
    finger_index = Column(Integer, nullable=False)

    employee = relationship("Employee", back_populates="fingerprints")
