import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class AttendanceRecordsRepository {
  Future<Either<Failure, List<EmployeeFingerprintReport>>> getEmployeeFingerprintReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<AttendanceSummaryReport>>> getAttendanceSummaryReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<DetailedDailyReport>>> getDetailedDailyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<DetailedDailyReport>>> getAttendanceOnlyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<DetailedDailyReport>>> getAbsenceOnlyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<DetailedDailyReport>>> getLateAttendanceReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });

  Future<Either<Failure, List<DetailedDailyReport>>> getAbsenceWithDeductionsReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  });
}
