from zk import ZK
from typing import List, Iterator, Optional
from datetime import datetime
from app.models.biometric_device import BiometricDevice
from app.services.safe_decode_time import safe_decode_time

from app.services.device_controller import (
    BiometricDeviceController,
    BiometricUser,
    BiometricAttendance,
    BiometricTemplate
)


class ZktecoK40Controller(BiometricDeviceController):
    """
    Implementation of BiometricDeviceController for ZKTeco K40 devices.
    Follows the DeviceManager pattern from fingerprint_python project.
    """

    def __init__(self, device: BiometricDevice, password: int = 0,
                 force_udp: bool = True, timeout: int = 5):
        self.device = device
        self._password = password
        self._force_udp = force_udp
        self._timeout = timeout
        self._zk: Optional[ZK] = None
        self.conn = None
        self._init_zk()

    def _init_zk(self):
        self._zk = ZK(
            self.device.ip_address,
            port=self.device.port,
            timeout=self._timeout,
            password=self._password,
            force_udp=self._force_udp,
        )
        setattr(self._zk, "_ZK__decode_time", safe_decode_time.__get__(self._zk, ZK))

    @property
    def is_connected(self) -> bool:
        return self.conn is not None and bool(self.conn)

    def connect(self) -> bool:
        try:
            assert self._zk is not None
            self.conn = self._zk.connect()
            return True
        except Exception as e:
            print(f"Error connecting to device: {e}")
            self.conn = None
            return False

    def disconnect(self) -> bool:
        if not self.conn:
            return True
        try:
            self.conn.enable_device()
        except Exception:
            pass
        try:
            self.conn.disconnect()
            self.conn = None
            return True
        except Exception:
            self.conn = None
            return False

    def disable_device(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.disable_device()
            return True
        except Exception:
            return False

    def enable_device(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.enable_device()
            return True
        except Exception:
            return False

    def restart(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.restart()
            return True
        except Exception:
            return False

    def poweroff(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.poweroff()
            return True
        except Exception:
            return False

    def get_attendance(self) -> List[BiometricAttendance]:
        if not self.conn:
            return []
        try:
            attendances = self.conn.get_attendance()
            if not attendances:
                return []
            return [
                BiometricAttendance(
                    user_id=str(att.user_id),
                    timestamp=att.timestamp,
                    status=att.status,
                    punch_type=getattr(att, 'punch', 0)
                )
                for att in attendances
            ]
        except Exception as e:
            print(f"Error fetching attendance: {e}")
            return []

    def clear_attendance(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.clear_attendance()
            return True
        except Exception:
            return False

    def get_users(self) -> List[BiometricUser]:
        if not self.conn:
            return []
        try:
            users = self.conn.get_users()
            if not users:
                return []
            return [
                BiometricUser(
                    uid=u.uid,
                    user_id=str(u.user_id),
                    name=u.name,
                    privilege=u.privilege,
                    password=u.password,
                    group_id=str(u.group_id),
                    card=u.card
                )
                for u in users
            ]
        except Exception as e:
            print(f"Error fetching users: {e}")
            return []

    def set_user(self, user: BiometricUser) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.set_user(
                uid=user.uid,
                name=user.name,
                privilege=user.privilege,
                password=user.password,
                group_id=user.group_id,
                user_id=user.user_id,
                card=user.card
            )
            return True
        except Exception as e:
            print(f"Error setting user: {e}")
            return False

    def delete_user(self, uid: int = 0, user_id: str = '') -> bool:
        if not self.conn:
            return False
        try:
            self.conn.delete_user(uid=uid, user_id=user_id)
            return True
        except Exception:
            return False

    def get_templates(self) -> List[BiometricTemplate]:
        if not self.conn:
            return []
        try:
            templates = self.conn.get_templates()
            if not templates:
                return []
            return [
                BiometricTemplate(
                    uid=t.uid,
                    size=t.size,
                    valid=t.valid,
                    template=t.template,
                    mark=t.fid
                )
                for t in templates
            ]
        except Exception:
            return []

    def get_user_template(self, uid: int, temp_id: int = 0, user_id: str = '') -> Optional[BiometricTemplate]:
        if not self.conn:
            return None
        try:
            t = self.conn.get_user_template(uid=uid, temp_id=temp_id, user_id=user_id)
            if t:
                return BiometricTemplate(
                    uid=t.uid,
                    size=t.size,
                    valid=t.valid,
                    template=t.template,
                    mark=t.fid
                )
            return None
        except Exception:
            return None

    def save_user_template(self, user: BiometricUser, templates: List[BiometricTemplate]) -> bool:
        if not self.conn:
            return False
        try:
            from zk.user import User
            from zk.finger import Finger

            zk_user = User(
                uid=user.uid,
                name=user.name,
                privilege=user.privilege,
                password=user.password,
                group_id=user.group_id,
                user_id=user.user_id,
                card=user.card
            )

            fingers = [
                Finger(uid=t.uid, fid=t.mark, valid=t.valid, template=t.template)
                for t in templates
            ]

            self.conn.save_user_template(user=zk_user, fingers=fingers)
            return True
        except Exception as e:
            print(f"Error saving template: {e}")
            return False

    def delete_user_template(self, uid: int = 0, temp_id: int = 0, user_id: str = '') -> bool:
        if not self.conn:
            return False
        try:
            self.conn.delete_user_template(uid=uid, temp_id=temp_id, user_id=user_id)
            return True
        except Exception:
            return False

    def enroll_user(self, uid: int = 0, temp_id: int = 0, user_id: str = '') -> bool:
        if not self.conn:
            return False
        try:
            self.conn.enroll_user(uid=uid, temp_id=temp_id, user_id=user_id)
            return True
        except Exception:
            return False

    def get_device_name(self) -> str:
        if not self.conn:
            return ''
        try:
            return self.conn.get_device_name()
        except Exception:
            return ''

    def get_serialnumber(self) -> str:
        if not self.conn:
            return ''
        try:
            return self.conn.get_serialnumber()
        except Exception:
            return ''

    def get_mac(self) -> str:
        if not self.conn:
            return ''
        try:
            return self.conn.get_mac()
        except Exception:
            return ''

    def get_firmware_version(self) -> str:
        if not self.conn:
            return ''
        try:
            return self.conn.get_firmware_version()
        except Exception:
            return ''

    def get_platform(self) -> str:
        if not self.conn:
            return ''
        try:
            return self.conn.get_platform()
        except Exception:
            return ''

    def get_pin_width(self) -> int:
        if not self.conn:
            return 0
        try:
            return self.conn.get_pin_width()
        except Exception:
            return 0

    def read_sizes(self) -> dict:
        if not self.conn:
            return {}
        try:
            self.conn.read_sizes()
            return {
                'users': self.conn.users,
                'users_cap': self.conn.users_cap,
                'fingers': self.conn.fingers,
                'fingers_cap': self.conn.fingers_cap,
                'records': self.conn.records,
                'rec_cap': self.conn.rec_cap,
                'faces': self.conn.faces,
                'faces_cap': self.conn.faces_cap,
            }
        except Exception:
            return {}

    def get_network_params(self) -> dict:
        if not self.conn:
            return {'ip': '', 'mask': '', 'gateway': ''}
        try:
            return self.conn.get_network_params()
        except Exception:
            return {'ip': '', 'mask': '', 'gateway': ''}

    def get_time(self) -> datetime:
        if not self.conn:
            return datetime.now()
        try:
            return self.conn.get_time()
        except Exception:
            return datetime.now()

    def set_time(self, timestamp: datetime) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.set_time(timestamp)
            return True
        except Exception:
            return False

    def unlock(self, time: int = 3) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.unlock(time=time)
            return True
        except Exception:
            return False

    def live_capture(self, new_timeout: int = 10) -> Iterator[BiometricAttendance]:
        if not self.conn:
            return
        try:
            for att in self.conn.live_capture(new_timeout=new_timeout):
                if att is None:
                    continue
                yield BiometricAttendance(
                    user_id=str(att.user_id),
                    timestamp=att.timestamp,
                    status=att.status,
                    punch_type=getattr(att, 'punch', 0)
                )
        except Exception as e:
            print(f"Error in live capture: {e}")

    def test_voice(self, index: int = 0) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.test_voice(index=index)
            return True
        except Exception:
            return False

    def clear_data(self) -> bool:
        if not self.conn:
            return False
        try:
            self.conn.clear_data()
            return True
        except Exception:
            return False
