from sqlalchemy import Column, Integer, String, Boolean, DateTime, Date
from app.config.database import Base


class BiometricDevice(Base):
    __tablename__ = "biometric_devices"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    device_type = Column(String(100), nullable=False)
    ip_address = Column(String(50), nullable=False, unique=True)
    port = Column(Integer, nullable=False, default=4370)
    is_online = Column(Boolean, nullable=False, default=False)
    last_sync = Column(DateTime)
    last_request_date = Column(Date, nullable=True)
