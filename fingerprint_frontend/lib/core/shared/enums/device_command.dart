enum DeviceCommand {
  disableDevice,
  enableDevice,
  restart,
  poweroff,
  clearAttendance,
  enrollUser,
  getDeviceName,
  getSerialnumber,
  getMac,
  getFirmwareVersion,
  getNetworkParams,
  getTime,
  setTime,
  unlock,
  testVoice,
  clearData,
  ping,
}

extension DeviceCommandExt on DeviceCommand {
  String get apiName {
    switch (this) {
      case DeviceCommand.disableDevice:
        return 'disable_device';
      case DeviceCommand.enableDevice:
        return 'enable_device';
      case DeviceCommand.restart:
        return 'restart';
      case DeviceCommand.poweroff:
        return 'poweroff';
      case DeviceCommand.clearAttendance:
        return 'clear_attendance';
      case DeviceCommand.enrollUser:
        return 'enroll_user';
      case DeviceCommand.getDeviceName:
        return 'get_device_name';
      case DeviceCommand.getSerialnumber:
        return 'get_serialnumber';
      case DeviceCommand.getMac:
        return 'get_mac';
      case DeviceCommand.getFirmwareVersion:
        return 'get_firmware_version';
      case DeviceCommand.getNetworkParams:
        return 'get_network_params';
      case DeviceCommand.getTime:
        return 'get_time';
      case DeviceCommand.setTime:
        return 'set_time';
      case DeviceCommand.unlock:
        return 'unlock';
      case DeviceCommand.testVoice:
        return 'test_voice';
      case DeviceCommand.clearData:
        return 'clear_data';
      case DeviceCommand.ping:
        return 'ping';
    }
  }

  String get displayName {
    switch (this) {
      case DeviceCommand.disableDevice:
        return 'تعطيل الجهاز';
      case DeviceCommand.enableDevice:
        return 'تفعيل الجهاز';
      case DeviceCommand.restart:
        return 'إعادة التشغيل';
      case DeviceCommand.poweroff:
        return 'إيقاف التشغيل';
      case DeviceCommand.clearAttendance:
        return 'مسح سجلات الحضور';
      case DeviceCommand.enrollUser:
        return 'تسجيل مستخدم جديد';
      case DeviceCommand.getDeviceName:
        return 'اسم الجهاز';
      case DeviceCommand.getSerialnumber:
        return 'الرقم التسلسلي';
      case DeviceCommand.getMac:
        return 'عنوان MAC';
      case DeviceCommand.getFirmwareVersion:
        return 'إصدار البرنامج الثابت';
      case DeviceCommand.getNetworkParams:
        return 'إعدادات الشبكة';
      case DeviceCommand.getTime:
        return 'وقت الجهاز';
      case DeviceCommand.setTime:
        return 'ضبط الوقت';
      case DeviceCommand.unlock:
        return 'فتح القفل';
      case DeviceCommand.testVoice:
        return 'اختبار الصوت';
      case DeviceCommand.clearData:
        return 'مسح كل البيانات';
      case DeviceCommand.ping:
        return 'اختبار الاتصال';
    }
  }
}
