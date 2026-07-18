import 'dart:async';

import 'package:fingerprint_frontend/core/network/websocket_client.dart';
import 'package:fingerprint_frontend/core/shared/entities/biometric_device_entity.dart';
import 'package:fingerprint_frontend/core/shared/enums/device_command.dart';
import 'package:fingerprint_frontend/core/shared/enums/device_state.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';

class LiveAttendanceEvent {
  final int deviceId;
  final String biometricId;
  final bool isCheckIn;
  final DateTime timestamp;

  const LiveAttendanceEvent({
    required this.deviceId,
    required this.biometricId,
    required this.isCheckIn,
    required this.timestamp,
  });

  factory LiveAttendanceEvent.fromMap(Map<String, dynamic> map) {
    return LiveAttendanceEvent(
      deviceId: map['device_id'] as int,
      biometricId: map['biometric_id'] as String,
      isCheckIn: map['is_check_in'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class BiometricDeviceController {
  final BiometricDeviceEntity device;
  final BiometricDevicesRepository _repository;
  final BiometricWebSocketClient _wsClient;

  final _stateController = StreamController<DeviceControllerState>.broadcast();
  final _liveController = StreamController<LiveAttendanceEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  DeviceControllerState _currentState = DeviceControllerState.idle;
  bool _liveCaptureActive = false;

  BiometricDeviceController({
    required this.device,
    required BiometricDevicesRepository repository,
    required BiometricWebSocketClient wsClient,
  }) : _repository = repository,
       _wsClient = wsClient;

  Stream<DeviceControllerState> get stateStream => _stateController.stream;
  DeviceControllerState get currentState => _currentState;

  Stream<LiveAttendanceEvent> get liveStream => _liveController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isLiveCaptureActive => _liveCaptureActive;

  void _updateState(DeviceControllerState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  Future<T?> _executeCommand<T>(
    DeviceCommand command, [
    Map<String, dynamic>? kwargs,
  ]) async {
    _updateState(DeviceControllerState.connected);
    final result = await _repository.executeDeviceCommand(
      device.id,
      command.apiName,
      kwargs,
    );
    return result.fold(
      (failure) {
        _errorController.add(failure.message);
        _updateState(DeviceControllerState.connected);
        return null;
      },
      (data) {
        _updateState(DeviceControllerState.connected);
        return data as T?;
      },
    );
  }

  // ========================
  // Connection
  // ========================

  Future<bool> connect() async {
    _updateState(DeviceControllerState.connecting);
    final result = await _repository.pingDevice(device.id);
    return result.fold(
      (failure) {
        _errorController.add(failure.message);
        _updateState(DeviceControllerState.error);
        return false;
      },
      (isOnline) {
        if (isOnline) {
          _updateState(DeviceControllerState.connected);
          return true;
        } else {
          _errorController.add('الجهاز غير متصل بالشبكة');
          _updateState(DeviceControllerState.disconnected);
          return false;
        }
      },
    );
  }

  void disconnect() {
    stopLiveCapture();
    _updateState(DeviceControllerState.disconnected);
  }

  // ========================
  // Device Control Commands
  // ========================

  Future<bool> unlock({int time = 3}) async {
    final result = await _executeCommand<bool>(DeviceCommand.unlock, {
      'time': time,
    });
    return result ?? false;
  }

  Future<bool> restart() async {
    final result = await _executeCommand<bool>(DeviceCommand.restart);
    return result ?? false;
  }

  Future<bool> poweroff() async {
    final result = await _executeCommand<bool>(DeviceCommand.poweroff);
    return result ?? false;
  }

  Future<bool> enableDevice() async {
    final result = await _executeCommand<bool>(DeviceCommand.enableDevice);
    return result ?? false;
  }

  Future<bool> disableDevice() async {
    final result = await _executeCommand<bool>(DeviceCommand.disableDevice);
    return result ?? false;
  }

  Future<bool> testVoice({int index = 0}) async {
    final result = await _executeCommand<bool>(DeviceCommand.testVoice, {
      'index': index,
    });
    return result ?? false;
  }

  Future<bool> clearAttendance() async {
    final result = await _executeCommand<bool>(DeviceCommand.clearAttendance);
    return result ?? false;
  }

  Future<bool> clearData() async {
    final result = await _executeCommand<bool>(DeviceCommand.clearData);
    return result ?? false;
  }

  // ========================
  // Device Info Commands
  // ========================

  Future<Map<String, dynamic>?> getAllProperties() async {
    final results = await Future.wait([
      getDeviceName(),
      getFirmwareVersion(),
      getSerialNumber(),
      getTime(),
      getMac(),
      getNetworkParams(),
    ], eagerError: true);
    return {
      'deviceName': results[0],
      'firmwareVersion': results[1],
      'serialNumber': results[2],
      'time': results[3],
      'mac': results[4],
      'networkParams': results[5],
    };
  }

  Future<String?> getDeviceName() async {
    return _executeCommand<String>(DeviceCommand.getDeviceName);
  }

  Future<String?> getSerialNumber() async {
    return _executeCommand<String>(DeviceCommand.getSerialnumber);
  }

  Future<String?> getMac() async {
    return _executeCommand<String>(DeviceCommand.getMac);
  }

  Future<String?> getFirmwareVersion() async {
    return _executeCommand<String>(DeviceCommand.getFirmwareVersion);
  }

  Future<Map<String, dynamic>?> getNetworkParams() async {
    return _executeCommand<Map<String, dynamic>>(
      DeviceCommand.getNetworkParams,
    );
  }

  Future<DateTime?> getTime() async {
    final result = await _executeCommand<String>(DeviceCommand.getTime);
    if (result == null) return null;
    return DateTime.tryParse(result);
  }

  Future<bool> setTime(DateTime timestamp) async {
    final isoString = timestamp.toIso8601String();
    final result = await _executeCommand<bool>(DeviceCommand.setTime, {
      'timestamp': isoString,
    });
    return result ?? false;
  }

  // ========================
  // Live Capture (WebSocket)
  // ========================

  void startLiveCapture() {
    if (_liveCaptureActive) return;
    _liveCaptureActive = true;

    _wsClient.connect(
      onMessageReceived: (data) {
        if (data['type'] == 'biometric_data' &&
            data['device_id'] == device.id) {
          final event = LiveAttendanceEvent.fromMap(data);
          _liveController.add(event);
        }
      },
      onError: (error) {
        _errorController.add('خطأ في الاتصال المباشر: $error');
      },
      onDone: () {
        _liveCaptureActive = false;
      },
    );

    _wsClient.registerDevice(device.id);
  }

  void stopLiveCapture() {
    if (!_liveCaptureActive) return;
    _wsClient.close();
    _liveCaptureActive = false;
  }

  // ========================
  // Cleanup
  // ========================

  void dispose() {
    stopLiveCapture();
    _stateController.close();
    _liveController.close();
    _errorController.close();
  }
}
