import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class BiometricDevicesRepository
    extends Repository<BiometricDeviceEntity, int> {
  Future<Either<Failure, bool>> pingDevice(int id);

  // Device Data Management
  Future<Either<Failure, List<DeviceUser>>> getDeviceUsers(int deviceId);
  Future<Either<Failure, void>> setDeviceUser(int deviceId, DeviceUser user);
  Future<Either<Failure, void>> deleteDeviceUser(
    int deviceId,
    int uid,
    String userId,
  );

  Future<Either<Failure, List<DeviceFingerprint>>> getDeviceTemplates(
    int deviceId,
  );
  Future<Either<Failure, void>> saveDeviceTemplates(
    int deviceId,
    DeviceUser user,
    List<DeviceFingerprint> templates,
  );
  Future<Either<Failure, void>> deleteDeviceTemplate(
    int deviceId,
    int uid,
    int tempId,
    String userId,
  );

  // Device Commands
  Future<Either<Failure, dynamic>> executeDeviceCommand(
    int deviceId,
    String command, [
    Map<String, dynamic>? kwargs,
  ]);
}
