import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/fingerprint_device_repository_impl.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class FingerprintDeviceRepository {
  FingerprintDeviceRepository(BiometricDeviceEntity device);

  // ──────────────── Device State Commands ────────────────
  Future<Either<Failure, bool>> disableDevice();
  Future<Either<Failure, bool>> enableDevice();
  Future<Either<Failure, bool>> restartDevice();
  Future<Either<Failure, bool>> powerOff();
  Future<Either<Failure, bool>> unlock();

  // ──────────────── Data Commands ────────────────
  Future<Either<Failure, bool>> clearAttendance();
  Future<Either<Failure, bool>> clearData();

  // ──────────────── User Commands ────────────────
  Future<Either<Failure, bool>> enrollUser(DeviceUser user);

  // ──────────────── Info Commands ────────────────
  Future<Either<Failure, String>> getDeviceName();
  Future<Either<Failure, String>> getSerialNumber();
  Future<Either<Failure, String>> getMac();
  Future<Either<Failure, String>> getFirmwareVersion();

  // ──────────────── Network Commands ────────────────
  Future<Either<Failure, Map<String, dynamic>>> getNetworkParams();

  // ──────────────── Time Commands ────────────────
  Future<Either<Failure, Map<String, dynamic>>> getTime();
  Future<Either<Failure, bool>> setTime(DateTime time);

  // ──────────────── Test Commands ────────────────
  Future<Either<Failure, bool>> testVoice();
  Future<Either<Failure, bool>> ping();

  // ──────────────── Generic Command Executor ────────────────
  Future<Either<Failure, dynamic>> executeDeviceCommand(
    DeviceCommand command, {
    Map<String, dynamic>? kwargs,
  });

  // ──────────────── User Management ────────────────
  Future<Either<Failure, List<DeviceUser>>> getUsers();
  Future<Either<Failure, bool>> insertUser(DeviceUser user);
  Future<Either<Failure, bool>> deleteUser(DeviceUser user);

  // ──────────────── Fingerprint Management ────────────────
  Future<Either<Failure, List<DeviceFingerprint>>> getFingerprints();
  Future<Either<Failure, bool>> saveFingerprint(
    DeviceUser user,
    List<DeviceFingerprint> templates,
  );
  Future<Either<Failure, bool>> deleteFingerprint(
    DeviceFingerprint fingerprint,
  );

  // ──────────────── Attendance & Sync ────────────────
  Future<Either<Failure, List<Map<String, dynamic>>>> getAttendanceLogs();
  Future<Either<Failure, Map<String, dynamic>>> syncDeviceData();

  Stream<BiometricDeviceState> get stream;
}
