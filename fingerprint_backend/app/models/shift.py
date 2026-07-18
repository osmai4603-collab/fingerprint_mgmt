from datetime import time
from sqlalchemy import Column, Integer, String, Time, Boolean
from sqlalchemy.dialects.postgresql import ARRAY
from app.config.database import Base


class Shift(Base):
    __tablename__ = "shifts"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, unique=True)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    weekend_days = Column(ARRAY(Integer), nullable=True)
    before_start_time = Column(Time, nullable=False, default=time(0, 0))
    after_start_time = Column(Time, nullable=False, default=time(0, 0))
    before_end_time = Column(Time, nullable=False, default=time(0, 0))
    after_end_time = Column(Time, nullable=False, default=time(0, 0))
    max_attendance_time = Column(Time, nullable=False, default=time(0, 0))
    is_night_shift = Column(Boolean, nullable=False, default=False)
    accept_overtime = Column(Boolean, nullable=False, default=True)
