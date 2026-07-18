from abc import ABC, abstractmethod
from typing import Optional
from datetime import date
from app.models.payroll_period import PayrollPeriod


class PayrollPeriodRepository(ABC):
    @abstractmethod
    def get_by_id(self, period_id: int) -> Optional[PayrollPeriod]: ...

    @abstractmethod
    def get_current_open(self) -> Optional[PayrollPeriod]: ...

    @abstractmethod
    def get_by_date(self, punch_date: date) -> Optional[PayrollPeriod]: ...
