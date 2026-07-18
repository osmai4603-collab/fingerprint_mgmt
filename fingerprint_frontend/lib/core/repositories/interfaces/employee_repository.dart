import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class EmployeeRepository extends Repository<EmployeeEntity, int> {
  Future<Either<Failure, List<EmployeeModel>>> getActiveEmployees();
  Future<Either<Failure, EmployeeModel?>> getEmployeeByQuery({
    String? employeeId,
    int? cardNo,
  });
  Future<Either<Failure, EmployeeModel>> getEmployeeWithShift(int id);
  Future<Either<Failure, EmployeeSummaryModel>> getEmployeeSummary(int id);
  Future<Either<Failure, Map<String, dynamic>>> importEmployeesFromCsv(
    String csvContent,
  );
  Future<Either<Failure, List<EmployeeFingerprintModel>>> getFingerprints(
    int employeeId,
  );
  Future<Either<Failure, EmployeeFingerprintModel>> addFingerprint(
    EmployeeFingerprintEntity entity,
  );
  Future<Either<Failure, void>> deleteFingerprint(
    int employeeId,
    int fingerprintId,
  );
  Future<Either<Failure, FingerprintSearchResult>> searchEmployeeByFingerprint(
    String biometric,
  );
  Future<Either<Failure, void>> toggleStatus(int employeeId, bool isActive);
}
