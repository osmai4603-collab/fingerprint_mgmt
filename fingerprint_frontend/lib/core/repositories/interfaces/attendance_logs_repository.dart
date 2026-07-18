import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class AttendanceLogsRepository
    extends Repository<AttendanceLogEntity, int> {
  Future<Either<Failure, List<AttendanceLogModel>>> getAttendanceLogs({
    int? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    bool unrecognizedOnly = false,
  });
  Future<Either<Failure, void>> linkLog(int logId, int employeeId);
  Future<Either<Failure, void>> addManualPunch(
    int employeeId,
    DateTime punchTime, {
    int? deviceId,
  });

  // Device Attendance
  Future<Either<Failure, List<DeviceAttendanceLog>>> getDeviceAttendance(
    int deviceId, {
    DateTime? startDate,
  });
  Future<Either<Failure, Map<String, dynamic>>> syncDeviceData(int deviceId);
}
