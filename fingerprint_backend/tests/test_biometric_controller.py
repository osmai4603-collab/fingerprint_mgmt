"""
Standalone test script for ZktecoK40Controller.
Tests all operations against a real device and writes results to docs/biometric_controller_test_results.md.
"""
from app.models.biometric_device import BiometricDevice
import sys
import os
from datetime import datetime
from types import SimpleNamespace

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.services.zkteco_k40_controller import ZktecoK40Controller
from app.services.device_controller import BiometricUser, BiometricTemplate

DEVICE_ID = 1
DEVICE_IP = "10.205.105.16"
DEVICE_PORT = 4370
DEVICE_TYPE = "ztkeco"

results = []


def record(category: str, operation: str, status: str, detail: str):
    results.append({
        "category": category,
        "operation": operation,
        "status": status,
        "detail": detail,
    })
    symbol = "✓" if status == "PASS" else "✗" if status == "FAIL" else "⊘"
    print(f"  [{symbol}] {operation}: {detail}")


def create_device():
    return BiometricDevice(
        id=DEVICE_ID,
        name="ZKTeco K40 - Main Entrance",
        device_type=DEVICE_TYPE,
        ip_address=DEVICE_IP,
        port=DEVICE_PORT,
        is_online=False,
        last_sync=None,
    )


def test_connection(ctrl: ZktecoK40Controller):
    print("\n=== Connection & Device State ===")
    category = "Connection & Device State"

    op = "connect"
    try:
        result = ctrl.connect()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "is_connected"
    try:
        result = ctrl.is_connected
        record(category, op, "PASS", f"is_connected={result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "disconnect"
    try:
        result = ctrl.disconnect()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "connect (re-connect)"
    try:
        result = ctrl.connect()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "disable_device"
    try:
        result = ctrl.disable_device()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "enable_device"
    try:
        result = ctrl.enable_device()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "restart"
    try:
        result = ctrl.restart()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "poweroff"
    try:
        result = ctrl.poweroff()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def test_attendance(ctrl: ZktecoK40Controller):
    print("\n=== Attendance Management ===")
    category = "Attendance Management"

    op = "get_attendance"
    try:
        records_list = ctrl.get_attendance()
        record(category, op, "PASS", f"returned {len(records_list)} records")
        for att in records_list[:5]:
            print(f"       -> user_id={att.user_id}, timestamp={att.timestamp}, status={att.status}, punch={att.punch_type}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "clear_attendance"
    try:
        result = ctrl.clear_attendance()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def test_users(ctrl: ZktecoK40Controller):
    print("\n=== User Management ===")
    category = "User Management"

    op = "get_users"
    try:
        users = ctrl.get_users()
        record(category, op, "PASS", f"returned {len(users)} users")
        for u in users[:5]:
            print(f"       -> uid={u.uid}, user_id={u.user_id}, name={u.name}, privilege={u.privilege}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    test_user = BiometricUser(
        uid=99,
        user_id="TEST001",
        name="Test User",
        privilege=0,
        password="",
        group_id="0",
        card=0,
    )

    op = "set_user"
    try:
        result = ctrl.set_user(test_user)
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "delete_user"
    try:
        result = ctrl.delete_user(uid=99, user_id="TEST001")
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def test_templates(ctrl: ZktecoK40Controller):
    print("\n=== Biometric Templates Management ===")
    category = "Biometric Templates"

    op = "get_templates"
    try:
        templates = ctrl.get_templates()
        record(category, op, "PASS", f"returned {len(templates)} templates")
        for t in templates[:5]:
            print(f"       -> uid={t.uid}, size={t.size}, valid={t.valid}, mark={t.mark}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_user_template"
    try:
        tmpl = ctrl.get_user_template(uid=1, temp_id=0)
        if tmpl:
            record(category, op, "PASS", f"uid={tmpl.uid}, size={tmpl.size}, valid={tmpl.valid}")
        else:
            record(category, op, "PASS", "returned None (no template found)")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    test_user = BiometricUser(uid=99, user_id="TEST001", name="Test User")
    test_tmpl = BiometricTemplate(uid=99, size=0, valid=1, template="", mark=0)

    op = "save_user_template"
    try:
        result = ctrl.save_user_template(test_user, [test_tmpl])
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "delete_user_template"
    try:
        result = ctrl.delete_user_template(uid=99, temp_id=0)
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "enroll_user"
    try:
        result = ctrl.enroll_user(uid=1, temp_id=0)
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def test_device_info(ctrl: ZktecoK40Controller):
    print("\n=== Device Information & Settings ===")
    category = "Device Info & Settings"

    op = "get_device_name"
    try:
        name = ctrl.get_device_name()
        record(category, op, "PASS", f"device_name='{name}'")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_serialnumber"
    try:
        sn = ctrl.get_serialnumber()
        record(category, op, "PASS", f"serial_number='{sn}'")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_platform"
    try:
        platform = ctrl.get_platform()
        record(category, op, "PASS", f"platform='{platform}'")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_mac"
    try:
        mac = ctrl.get_mac()
        record(category, op, "PASS", f"mac='{mac}'")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_firmware_version"
    try:
        fw = ctrl.get_firmware_version()
        record(category, op, "PASS", f"firmware='{fw}'")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_pin_width"
    try:
        pw = ctrl.get_pin_width()
        record(category, op, "PASS", f"pin_width={pw}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_network_params"
    try:
        net = ctrl.get_network_params()
        record(category, op, "PASS", f"network_params={net}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "get_time"
    try:
        t = ctrl.get_time()
        record(category, op, "PASS", f"device_time={t}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "set_time"
    try:
        result = ctrl.set_time(datetime.now())
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "read_sizes"
    try:
        sizes = ctrl.read_sizes()
        record(category, op, "PASS", f"sizes={sizes}")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def test_live_control(ctrl: ZktecoK40Controller):
    print("\n=== Live Control ===")
    category = "Live Control"

    op = "unlock"
    try:
        result = ctrl.unlock(time=3)
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "test_voice"
    try:
        result = ctrl.test_voice(index=0)
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "clear_data"
    try:
        result = ctrl.clear_data()
        record(category, op, "PASS" if result else "FAIL", f"returned {result}")
    except Exception as e:
        record(category, op, "FAIL", str(e))

    op = "live_capture"
    try:
        count = 0
        for att in ctrl.live_capture(new_timeout=5):
            count += 1
            print(f"       -> live: user_id={att.user_id}, timestamp={att.timestamp}")
            if count >= 3:
                break
        record(category, op, "PASS", f"captured {count} events in 5s timeout")
    except Exception as e:
        record(category, op, "FAIL", str(e))


def generate_report():
    total = len(results)
    passed = sum(1 for r in results if r["status"] == "PASS")
    failed = sum(1 for r in results if r["status"] == "FAIL")

    lines = [
        "# تقرير اختبار ZktecoK40Controller",
        "",
        f"**التاريخ:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        "",
        "**المنهجية المتبعة:** مأخوذة من مشروع fingerprint_python (DeviceManager pattern)",
        "",
        "## معلومات الجهاز",
        "",
        "| الحقل | القيمة |",
        "|-------|--------|",
        f"| ID | {DEVICE_ID} |",
        f"| IP Address | {DEVICE_IP} |",
        f"| Port | {DEVICE_PORT} |",
        f"| Device Type | {DEVICE_TYPE} |",
        f"| Password | 0 |",
        f"| Force UDP | True |",
        f"| Timeout | 5s |",
        "",
        "## ملخص النتائج",
        "",
        "| الحالة | العدد |",
        "|--------|-------|",
        f"| ✓ نجاح (PASS) | {passed} |",
        f"| ✗ فشل (FAIL) | {failed} |",
        f"| **الإجمالي** | **{total}** |",
        "",
        "## تفاصيل النتائج",
        "",
        "| # | المجموعة | العملية | الحالة | التفاصيل |",
        "|---|----------|---------|--------|----------|",
    ]

    for i, r in enumerate(results, 1):
        status_icon = "✓ PASS" if r["status"] == "PASS" else "✗ FAIL"
        detail = r["detail"].replace("|", "\\|")
        lines.append(f"| {i} | {r['category']} | `{r['operation']}` | {status_icon} | {detail} |")

    lines.extend([
        "",
        "## التغييرات المطبقة من مشروع fingerprint_python",
        "",
        "| # | التغيير | الوصف |",
        "|---|---------|-------|",
        "| 1 | `safe_decode_time` monkey-patch | إصلاح bug في فك ترميز الأوقات من الجهاز |",
        "| 2 | فصل `conn` عن `_zk` | `self.conn = self._zk.connect()` بدلاً من التخزين المباشر |",
        "| 3 | `force_udp` + `password` | إضافة معاملات الاتصال المفقودة |",
        "| 4 | Guard clauses | `if not self.conn: return []` بدلاً من `raise Exception` |",
        "| 5 | `is_connected` property | خاصية للتحقق من حالة الاتصال |",
        "| 6 | `get_platform()` | جلب نوع/منصة الجهاز |",
        "| 7 | `get_pin_width()` | عرض عداد الأرقام في رقم الموظف |",
        "| 8 | `read_sizes()` | قراءة أحجام الذاكرة (مستخدمين/بصمات/سجلات/وجوه) |",
        "| 9 | Disconnect آمن | `enable_device()` قبل `disconnect()` |",
        "",
        "---",
        "*تم التوليد تلقائياً بواسطة test_biometric_controller.py*",
    ])

    return "\n".join(lines)


def main():
    print(f"╔══════════════════════════════════════════════╗")
    print(f"║  ZktecoK40Controller Test Suite              ║")
    print(f"║  Device: {DEVICE_IP}:{DEVICE_PORT}              ║")
    print(f"║  Method: DeviceManager pattern               ║")
    print(f"╚══════════════════════════════════════════════╝")

    device = create_device()
    print(f"\nDevice created: id={device.id}, name={device.name}")
    print(f"  ip={device.ip_address}, port={device.port}, type={device.device_type}")

    ctrl = ZktecoK40Controller(device)

    test_connection(ctrl)
    test_attendance(ctrl)
    test_users(ctrl)
    test_templates(ctrl)
    test_device_info(ctrl)
    test_live_control(ctrl)

    ctrl.disconnect()

    print(f"\n{'='*50}")
    print(f"Total: {len(results)} | PASS: {sum(1 for r in results if r['status']=='PASS')} | FAIL: {sum(1 for r in results if r['status']=='FAIL')}")

    report = generate_report()
    docs_dir = os.path.join(os.path.dirname(__file__), "..", "docs")
    os.makedirs(docs_dir, exist_ok=True)
    report_path = os.path.join(docs_dir, "biometric_controller_test_results.md")

    with open(report_path, "w", encoding="utf-8") as f:
        f.write(report)

    print(f"\nReport saved to: {os.path.abspath(report_path)}")


if __name__ == "__main__":
    main()
