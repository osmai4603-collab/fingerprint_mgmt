enum DeviceControllerState {
  idle,
  connecting,
  connected,
  executing,
  error,
  disconnected,
}

extension DeviceControllerStateExt on DeviceControllerState {
  String get displayLabel {
    switch (this) {
      case DeviceControllerState.idle:
        return 'جاهز';
      case DeviceControllerState.connecting:
        return 'جارٍ الاتصال...';
      case DeviceControllerState.connected:
        return 'متصل';
      case DeviceControllerState.executing:
        return 'جارٍ التنفيذ...';
      case DeviceControllerState.error:
        return 'خطأ';
      case DeviceControllerState.disconnected:
        return 'غير متصل';
    }
  }
}
