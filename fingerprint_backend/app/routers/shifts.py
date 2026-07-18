from fastapi import APIRouter, Depends, HTTPException, status
from app.models.app_user import AppUser
from app.schemas.shift import ShiftCreate, ShiftUpdate, ShiftResponse
from app.repositories import get_shift_repo
from app.repositories.interfaces.shift_repository import ShiftRepository
from app.middleware.auth import get_current_user

router = APIRouter(prefix="/api/shifts", tags=["Shifts"])


@router.get("/", response_model=list[ShiftResponse])
def get_shifts(
    repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    return repo.get_all()


@router.post("/", response_model=ShiftResponse, status_code=status.HTTP_201_CREATED)
def create_shift(
    data: ShiftCreate,
    repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if repo.exists_by_name(data.name):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Shift name already exists",
        )
    return repo.create(data)


@router.get("/{shift_id}", response_model=ShiftResponse)
def get_shift(
    shift_id: int,
    repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    shift = repo.get_by_id(shift_id)
    if not shift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shift not found")
    return shift


@router.put("/{shift_id}", response_model=ShiftResponse)
def update_shift(
    shift_id: int,
    data: ShiftUpdate,
    repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    shift = repo.get_by_id(shift_id)
    if not shift:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shift not found")

    if data.name and data.name != shift.name:
        if repo.exists_by_name(data.name, exclude_id=shift_id):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Shift name already exists",
            )

    updated = repo.update(shift_id, data)
    return updated


@router.delete("/{shift_id}")
def delete_shift(
    shift_id: int,
    repo: ShiftRepository = Depends(get_shift_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not repo.delete(shift_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Shift not found")
    return {"message": "Shift deleted successfully"}
