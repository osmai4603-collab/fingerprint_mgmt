from typing import Optional
from sqlalchemy.orm import Session
from app.models.employee import Employee
from app.schemas.employee import EmployeeCreate, EmployeeUpdate
from app.repositories.interfaces.employee_repository import EmployeeRepository
from app.utils.password_utils import PasswordUtils


class EmployeeRepositoryImpl(EmployeeRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_all(self, is_active: Optional[bool] = None) -> list[Employee]:
        query = self.db.query(Employee)
        if is_active is not None:
            query = query.filter(Employee.is_active == is_active)
        return query.all()

    def get_by_uid(self, uid: int) -> Optional[Employee]:
        return self.db.query(Employee).filter(Employee.uid == uid).first()

    def get_by_employee_id(self, employee_id: str) -> Optional[Employee]:
        return self.db.query(Employee).filter(Employee.employee_id == employee_id).first()

    def get_by_card_no(self, card_no: int) -> Optional[Employee]:
        return self.db.query(Employee).filter(Employee.card_no == card_no).first()

    def find(self, employee_id: Optional[str] = None, card_no: Optional[int] = None) -> Optional[Employee]:
        query = self.db.query(Employee)
        if employee_id:
            query = query.filter(Employee.employee_id == employee_id)
        if card_no:
            query = query.filter(Employee.card_no == card_no)
        return query.first()

    def create(self, data: EmployeeCreate) -> Employee:
        employee = Employee(
            employee_id=data.employee_id,
            name=data.name,
            role=data.role,
            group_id=data.group_id,
            card_no=data.card_no,
            default_shift_id=data.default_shift_id,
            password=PasswordUtils.hash_password(data.password) if data.password else None,
        )
        self.db.add(employee)
        self.db.commit()
        self.db.refresh(employee)
        return employee

    def update(self, employee_uid: int, data: EmployeeUpdate) -> Optional[Employee]:
        employee = self.get_by_uid(employee_uid)
        if not employee:
            return None
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            if field == "password":
                if value:
                    setattr(employee, field, PasswordUtils.hash_password(value))
            else:
                setattr(employee, field, value)
        self.db.commit()
        self.db.refresh(employee)
        return employee

    def soft_delete(self, employee_uid: int) -> bool:
        employee = self.get_by_uid(employee_uid)
        if not employee:
            return False
        employee.is_active = False
        self.db.commit()
        return True

    def exists_by_employee_id(self, employee_id: str, exclude_uid: Optional[int] = None) -> bool:
        query = self.db.query(Employee).filter(Employee.employee_id == employee_id)
        if exclude_uid is not None:
            query = query.filter(Employee.uid != exclude_uid)
        return query.first() is not None
