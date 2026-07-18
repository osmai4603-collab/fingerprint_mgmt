from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from app.config.database import get_db
from app.models.app_user import AppUser
from app.models.attendance import AttendanceLog
from app.schemas.device import DeviceCreate, DeviceUpdate, DeviceResponse, DeviceStatusResponse
from app.repositories import get_device_repo
from app.repositories.interfaces.biometric_device_repository import BiometricDeviceRepository
from app.middleware.auth import get_current_user
from datetime import datetime, date
from typing import List, Optional
from pydantic import BaseModel
from app.services.device_controller import BiometricUser, BiometricTemplate, BiometricAttendance
from app.services.zkteco_k40_controller import ZktecoK40Controller
from app.usecases.attendance import ProcessAttendanceLogUseCase

class DeviceTemplateSaveRequest(BaseModel):
    user: BiometricUser
    templates: List[BiometricTemplate]

class DeviceCommandRequest(BaseModel):
    command: str
    kwargs: dict = {}

router = APIRouter(prefix="/api/devices", tags=["Devices"])


@router.get("/", response_model=list[DeviceResponse])
def get_devices(
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    return repo.get_all()


@router.post("/", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
def create_device(
    data: DeviceCreate,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if repo.exists_by_ip(data.ip_address):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="IP address already exists",
        )

    device = repo.create(data)

    controller = ZktecoK40Controller(device)
    is_reachable = controller.connect()
    if is_reachable:
        controller.disconnect()
    repo.update(device.id, DeviceUpdate(is_online=is_reachable))
    return repo.get_by_id(device.id)


@router.get("/{device_id}", response_model=DeviceResponse)
def get_device(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    return device


@router.put("/{device_id}", response_model=DeviceResponse)
def update_device(
    device_id: int,
    data: DeviceUpdate,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    if data.ip_address and data.ip_address != device.ip_address:
        if repo.exists_by_ip(data.ip_address, exclude_id=device_id):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="IP address already exists",
            )

    updated = repo.update(device_id, data)
    if data.ip_address or data.port:
        controller = ZktecoK40Controller(updated)
        is_reachable = controller.connect()
        if is_reachable:
            controller.disconnect()
        repo.update(device_id, DeviceUpdate(is_online=is_reachable))

    return repo.get_by_id(device_id)


@router.delete("/{device_id}")
def delete_device(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    if not repo.delete(device_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")
    return {"message": "Device deleted successfully"}


@router.get("/{device_id}/status", response_model=DeviceStatusResponse)
def get_device_status(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    is_reachable = controller.connect()
    if is_reachable:
        controller.disconnect()

    repo.update(device_id, DeviceUpdate(is_online=is_reachable))

    return DeviceStatusResponse(
        device_id=device.id,
        name=device.name,
        ip_address=device.ip_address,
        is_online=is_reachable,
        port=device.port,
        last_sync=device.last_sync,
    )


@router.get("/{device_id}/users", response_model=List[BiometricUser])
def get_device_users(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    users = controller.get_users()
    controller.disconnect()
    return users


@router.post("/{device_id}/users", status_code=status.HTTP_200_OK)
def set_device_user(
    device_id: int,
    user: BiometricUser,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    success = controller.set_user(user)
    controller.disconnect()
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to set user on device")
    return {"message": "User set successfully"}


@router.delete("/{device_id}/users/{uid}")
def delete_device_user(
    device_id: int,
    uid: int,
    user_id: str = "",
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    success = controller.delete_user(uid=uid, user_id=user_id)
    controller.disconnect()
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete user on device")
    return {"message": "User deleted successfully"}


@router.get("/{device_id}/templates", response_model=List[BiometricTemplate])
def get_device_templates(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    templates = controller.get_templates()
    controller.disconnect()
    return templates


@router.post("/{device_id}/templates", status_code=status.HTTP_200_OK)
def set_device_templates(
    device_id: int,
    data: DeviceTemplateSaveRequest,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    success = controller.save_user_template(data.user, data.templates)
    controller.disconnect()
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to save template on device")
    return {"message": "Templates saved successfully"}


@router.delete("/{device_id}/templates/{uid}")
def delete_device_template(
    device_id: int,
    uid: int,
    temp_id: int = 0,
    user_id: str = "",
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    success = controller.delete_user_template(uid=uid, temp_id=temp_id, user_id=user_id)
    controller.disconnect()
    if not success:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to delete template on device")
    return {"message": "Template deleted successfully"}


@router.get("/{device_id}/attendance", response_model=List[BiometricAttendance])
def get_device_attendance(
    device_id: int,
    start_date: Optional[str] = Query(None, description="Format: YYYY-MM-DD or DD-MM-YYYY"),
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    db: Session = Depends(get_db),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    start_date_obj = None
    if start_date:
        for fmt in ("%Y-%m-%d", "%d-%m-%Y"):
            try:
                start_date_obj = datetime.strptime(start_date, fmt).date()
                break
            except ValueError:
                pass
        if not start_date_obj:
            raise HTTPException(status_code=400, detail="Invalid date format. Use YYYY-MM-DD or DD-MM-YYYY")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    try:
        attendance = controller.get_attendance()

        filtered = []
        now_date = datetime.now().date()

        for att in attendance:
            att_date = att.timestamp.date()
            if start_date_obj:
                if att_date < start_date_obj or att_date > now_date:
                    continue
            filtered.append(att)

        device = repo.get_by_id(device_id)
        device.last_request_date = now_date
        db.commit()

        return filtered
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    finally:
        controller.disconnect()


@router.post("/{device_id}/sync")
def sync_device_data(
    device_id: int,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    db: Session = Depends(get_db),  # Temporary: use cases still need Session
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)
    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    try:
        attendances = controller.get_attendance()
        processor = ProcessAttendanceLogUseCase(db)
        new_logs_count = 0

        for att in attendances:
            existing_log = db.query(AttendanceLog).filter(
                AttendanceLog.employee_id == int(att.user_id),
                AttendanceLog.punch_time == att.timestamp,
                AttendanceLog.device_id == device_id
            ).first()

            if not existing_log:
                log = AttendanceLog(
                    employee_id=int(att.user_id),
                    device_id=device_id,
                    punch_time=att.timestamp,
                )
                db.add(log)
                db.commit()
                db.refresh(log)

                try:
                    processor.execute(log)
                except Exception as e:
                    print(f"Error processing log {log.id}: {e}")

                new_logs_count += 1

        repo.update(device_id, DeviceUpdate(last_sync=datetime.utcnow()))

        return {
            "message": "Sync successful",
            "new_logs_count": new_logs_count,
            "last_sync": datetime.utcnow()
        }
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    finally:
        controller.disconnect()


@router.post("/{device_id}/command")
def execute_device_command(
    device_id: int,
    request: DeviceCommandRequest,
    repo: BiometricDeviceRepository = Depends(get_device_repo),
    current_user: AppUser = Depends(get_current_user),
):
    device = repo.get_by_id(device_id)
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found")

    controller = ZktecoK40Controller(device)

    allowed_commands = [
        "disable_device", "enable_device", "restart", "poweroff",
        "clear_attendance", "enroll_user", "get_device_name",
        "get_serialnumber", "get_mac", "get_firmware_version",
        "get_network_params", "get_time", "set_time", "unlock",
        "test_voice", "clear_data", "ping"
    ]

    if request.command not in allowed_commands:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or unsupported command")

    if not hasattr(controller, request.command):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Command not found on controller")

    method = getattr(controller, request.command)

    if not controller.connect():
        raise HTTPException(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="Could not connect to device")

    try:
        result = method(**request.kwargs)
        return {"command": request.command, "result": result}
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Command execution failed: {str(e)}")
    finally:
        controller.disconnect()
