from typing import Optional
from sqlalchemy.orm import Session
from app.models.shift import Shift
from app.schemas.shift import ShiftCreate, ShiftUpdate
from app.repositories.interfaces.shift_repository import ShiftRepository


class ShiftRepositoryImpl(ShiftRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_all(self) -> list[Shift]:
        return self.db.query(Shift).all()

    def get_by_id(self, shift_id: int) -> Optional[Shift]:
        return self.db.query(Shift).filter(Shift.id == shift_id).first()

    def get_by_name(self, name: str) -> Optional[Shift]:
        return self.db.query(Shift).filter(Shift.name == name).first()

    def create(self, data: ShiftCreate) -> Shift:
        shift = Shift(**data.model_dump())
        self.db.add(shift)
        self.db.commit()
        self.db.refresh(shift)
        return shift

    def update(self, shift_id: int, data: ShiftUpdate) -> Optional[Shift]:
        shift = self.get_by_id(shift_id)
        if not shift:
            return None
        for field, value in data.model_dump(exclude_unset=True).items():
            setattr(shift, field, value)
        self.db.commit()
        self.db.refresh(shift)
        return shift

    def delete(self, shift_id: int) -> bool:
        shift = self.get_by_id(shift_id)
        if not shift:
            return False
        self.db.delete(shift)
        self.db.commit()
        return True

    def exists_by_name(self, name: str, exclude_id: Optional[int] = None) -> bool:
        query = self.db.query(Shift).filter(Shift.name == name)
        if exclude_id is not None:
            query = query.filter(Shift.id != exclude_id)
        return query.first() is not None
