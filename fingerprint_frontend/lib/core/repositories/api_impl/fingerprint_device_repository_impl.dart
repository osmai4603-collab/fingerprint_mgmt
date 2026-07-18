import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/fingerprint_device_repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

final class FingerprintDeviceRepositoryImpl
    implements FingerprintDeviceRepository {
  final BiometricDeviceEntity _device;
  final ApiClient _apiClient;

  final _controller = StreamController<BiometricDeviceState>.broadcast();

  FingerprintDeviceRepositoryImpl(this._device, this._apiClient);

  int get _deviceId => _device.id;

  // ──────────────── Internal Command Executor ────────────────

  Future<Either<Failure, dynamic>> _executeCommand(
    String command, [
    Map<String, dynamic>? kwargs,
  ]) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.deviceCommand(_deviceId),
        data: {
          'command': command,
          if (kwargs != null && kwargs.isNotEmpty) 'kwargs': kwargs,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Right(data['result']);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  // ──────────────── Device State Commands ────────────────

  @override
  Future<Either<Failure, bool>> disableDevice() async {
    final result = await _executeCommand(DeviceCommand.disableDevice.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> enableDevice() async {
    final result = await _executeCommand(DeviceCommand.enableDevice.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> restartDevice() async {
    final result = await _executeCommand(DeviceCommand.restart.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> powerOff() async {
    final result = await _executeCommand(DeviceCommand.poweroff.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> unlock() async {
    final result = await _executeCommand(DeviceCommand.unlock.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  // ──────────────── Data Commands ────────────────

  @override
  Future<Either<Failure, bool>> clearAttendance() async {
    final result = await _executeCommand(DeviceCommand.clearAttendance.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> clearData() async {
    final result = await _executeCommand(DeviceCommand.clearData.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  // ──────────────── User Commands ────────────────

  @override
  Future<Either<Failure, bool>> enrollUser(DeviceUser user) async {
    final result = await _executeCommand(
      DeviceCommand.enrollUser.apiName,
      user.toMap(),
    );
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  // ──────────────── Info Commands ────────────────

  @override
  Future<Either<Failure, String>> getDeviceName() async {
    final result = await _executeCommand(DeviceCommand.getDeviceName.apiName);
    return result.fold(Left.new, (r) => Right(r as String));
  }

  @override
  Future<Either<Failure, String>> getSerialNumber() async {
    final result = await _executeCommand(DeviceCommand.getSerialnumber.apiName);
    return result.fold(Left.new, (r) => Right(r as String));
  }

  @override
  Future<Either<Failure, String>> getMac() async {
    final result = await _executeCommand(DeviceCommand.getMac.apiName);
    return result.fold(Left.new, (r) => Right(r as String));
  }

  @override
  Future<Either<Failure, String>> getFirmwareVersion() async {
    final result = await _executeCommand(
      DeviceCommand.getFirmwareVersion.apiName,
    );
    return result.fold(Left.new, (r) => Right(r as String));
  }

  // ──────────────── Network Commands ────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> getNetworkParams() async {
    final result = await _executeCommand(
      DeviceCommand.getNetworkParams.apiName,
    );
    return result.fold(Left.new, (r) => Right(r as Map<String, dynamic>));
  }

  // ──────────────── Time Commands ────────────────

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTime() async {
    final result = await _executeCommand(DeviceCommand.getTime.apiName);
    return result.fold(Left.new, (r) => Right(r as Map<String, dynamic>));
  }

  @override
  Future<Either<Failure, bool>> setTime(DateTime time) async {
    final result = await _executeCommand(DeviceCommand.setTime.apiName, {
      'time': time.toIso8601String(),
    });
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  // ──────────────── Test Commands ────────────────

  @override
  Future<Either<Failure, bool>> testVoice() async {
    final result = await _executeCommand(DeviceCommand.testVoice.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  @override
  Future<Either<Failure, bool>> ping() async {
    final result = await _executeCommand(DeviceCommand.ping.apiName);
    return result.fold(Left.new, (r) => Right(r as bool));
  }

  // ──────────────── Generic Command Executor ────────────────

  @override
  Future<Either<Failure, dynamic>> executeDeviceCommand(
    DeviceCommand command, {
    Map<String, dynamic>? kwargs,
  }) {
    return _executeCommand(command.apiName, kwargs);
  }

  // ──────────────── User Management ────────────────

  @override
  Future<Either<Failure, List<DeviceUser>>> getUsers() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.deviceUsers(_deviceId),
      );
      final list = response.data as List<dynamic>;
      final users = list
          .map((e) => DeviceUser.fromMap(e as Map<String, dynamic>))
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> insertUser(DeviceUser user) async {
    try {
      await _apiClient.post(
        ApiEndpoints.deviceUsers(_deviceId),
        data: user.toMap(),
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteUser(DeviceUser user) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deviceUserDelete(_deviceId, user.uid!),
        queryParameters: {'user_id': user.userId},
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  // ──────────────── Fingerprint Management ────────────────

  @override
  Future<Either<Failure, List<DeviceFingerprint>>> getFingerprints() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.deviceTemplates(_deviceId),
      );
      final list = response.data as List<dynamic>;
      final templates = list
          .map((e) => DeviceFingerprint.fromMap(e as Map<String, dynamic>))
          .toList();
      return Right(templates);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveFingerprint(
    DeviceUser user,
    List<DeviceFingerprint> templates,
  ) async {
    try {
      await _apiClient.post(
        ApiEndpoints.deviceTemplates(_deviceId),
        data: {
          'user': user.toMap(),
          'templates': templates.map((t) => t.toMap()).toList(),
        },
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFingerprint(
    DeviceFingerprint fingerprint,
  ) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.deviceTemplateDelete(_deviceId, fingerprint.uid),
        queryParameters: {'temp_id': fingerprint.mark},
      );
      return const Right(true);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  // ──────────────── Attendance & Sync ────────────────

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
  getAttendanceLogs() async {
    try {
      final response = await _executeCommand('get_attendance_logs');
      return response.fold(
        Left.new,
        (r) => Right((r as List<dynamic>).cast<Map<String, dynamic>>()),
      );
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncDeviceData() async {
    try {
      final response = await _executeCommand('sync_data');
      return response.fold(Left.new, (r) => Right(r as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Stream<BiometricDeviceState> get stream {
    return _controller.stream;
  }
}

enum ConnectionState { connected, disconnected, connecting, executing }

sealed class BiometricDeviceState {
  final ConnectionState state;
  final bool isEnabled;
  final DateTime deviceTime;
  final String firmwareVersion;
  final String networkParams;
  final String deviceName;
  final String serialNumber;
  final String macAddress;

  BiometricDeviceState({
    required this.state,
    required this.isEnabled,
    required this.deviceName,
    required this.deviceTime,
    required this.firmwareVersion,
    required this.macAddress,
    required this.networkParams,
    required this.serialNumber,
  });
}
