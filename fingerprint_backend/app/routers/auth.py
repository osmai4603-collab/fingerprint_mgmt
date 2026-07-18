from fastapi import APIRouter, Depends, HTTPException, status
from app.models.app_user import AppUser
from app.schemas.auth import (
    LoginRequest, TokenResponse, RefreshRequest,
    CreateUserRequest, UpdateUserRequest, ChangePasswordRequest, UserResponse,
)
from app.repositories import get_app_user_repo
from app.repositories.interfaces.app_user_repository import AppUserRepository
from app.utils.jwt_utils import JwtUtils
from app.utils.password_utils import PasswordUtils
from app.utils.token_blacklist import token_blacklist
from app.middleware.auth import get_current_user

router = APIRouter(prefix="/api/auth", tags=["Auth"])


def _user_response(user: AppUser) -> UserResponse:
    return UserResponse(
        id=user.id,
        username=user.username,
        role=user.role,
        employee_id=user.employee_id,
        is_active=user.is_active,
        created_at=user.created_at,
        updated_at=user.updated_at,
    )


@router.post("/signup", response_model=UserResponse)
def signup(
    request: CreateUserRequest,
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if repo.exists_by_username(request.username):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists",
        )

    if request.role not in ("admin", "viewer", "hr"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid role. Allowed: admin, viewer, hr",
        )

    password_hash = PasswordUtils.hash_password(request.password)
    user = repo.create(request, password_hash)
    return _user_response(user)


@router.put("/users/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    request: UpdateUserRequest,
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    user = repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    if request.username is not None:
        if repo.exists_by_username(request.username, exclude_id=user_id):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken",
            )

    if request.role is not None and request.role not in ("admin", "viewer", "hr"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid role. Allowed: admin, viewer, hr",
        )

    updated = repo.update(user_id, request)
    return _user_response(updated)


@router.patch("/users/{user_id}/password")
def change_password(
    user_id: int,
    request: ChangePasswordRequest,
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not repo.change_password(user_id, PasswordUtils.hash_password(request.new_password)):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return {"message": "Password changed successfully"}


@router.patch("/users/{user_id}/status", response_model=UserResponse)
def toggle_status(
    user_id: int,
    request: dict,
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    user = repo.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    is_active = request.get("is_active", not user.is_active)
    from app.schemas.auth import UpdateUserRequest
    update_req = UpdateUserRequest(is_active=is_active)
    updated = repo.update(user_id, update_req)
    return _user_response(updated)


@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not repo.delete(user_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return {"message": "User deleted successfully"}


@router.post("/login", response_model=TokenResponse)
def login(
    request: LoginRequest,
    repo: AppUserRepository = Depends(get_app_user_repo),
):
    user = repo.get_by_username(request.username)
    if not user or not PasswordUtils.verify_password(request.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    token = JwtUtils.generate_token(
        user_id=user.id,
        username=user.username,
        role=user.role,
        employee_id=user.employee_id,
    )
    refresh_token = JwtUtils.generate_refresh_token(
        user_id=user.id,
        username=user.username,
        role=user.role,
        employee_id=user.employee_id,
    )

    return TokenResponse(
        token=token,
        refreshToken=refresh_token,
        user=_user_response(user),
    )


@router.post("/refresh", response_model=dict)
def refresh_token(
    request: RefreshRequest,
    repo: AppUserRepository = Depends(get_app_user_repo),
):
    payload = JwtUtils.verify_token(request.refreshToken)
    if not payload or payload.get("type") != "refresh":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user = repo.get_by_id(payload["userId"])
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )

    new_token = JwtUtils.generate_token(
        user_id=user.id,
        username=user.username,
        role=user.role,
        employee_id=user.employee_id,
    )
    new_refresh_token = JwtUtils.generate_refresh_token(
        user_id=user.id,
        username=user.username,
        role=user.role,
        employee_id=user.employee_id,
    )

    return {"token": new_token, "refreshToken": new_refresh_token}


@router.post("/logout")
def logout(
    current_user: AppUser = Depends(get_current_user),
    credentials: dict = None,
):
    return {"message": "Logged out successfully"}


@router.get("/getusers")
def get_users(
    repo: AppUserRepository = Depends(get_app_user_repo),
    current_user: AppUser = Depends(get_current_user),
):
    users = repo.get_all()
    return [_user_response(u) for u in users]
