import sys
import os
sys.path.insert(0, ".")
from app.services.zkteco_k40_controller import ZktecoK40Controller
from app.models.biometric_device import BiometricDevice
from zk.finger import Finger
from unittest.mock import MagicMock

device = BiometricDevice(id=1, ip_address="1.1.1.1", port=4370)
ctrl = ZktecoK40Controller(device)

ctrl.conn = MagicMock()
mock_finger = Finger(uid=1, fid=0, valid=1, template=b"some_mock_template_data")
ctrl.conn.get_templates.return_value = [mock_finger]

try:
    templates = ctrl.get_templates()
    print("SUCCESS, templates parsed!")
    for t in templates:
        print(f"uid={t.uid}, size={t.size}, valid={t.valid}, mark={t.mark}")
except Exception as e:
    print("FAILED:", e)
    import traceback
    traceback.print_exc()
