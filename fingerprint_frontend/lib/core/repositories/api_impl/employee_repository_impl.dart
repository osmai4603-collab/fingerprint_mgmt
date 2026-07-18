import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final ApiClient _apiClient;

  EmployeeRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<EmployeeEntity>>> get() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.employees);
      final employees = list.map((e) => EmployeeModel.fromMap(e)).toList();
      return Right(employees);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> getById(int id) async {
    try {
      final data = await _apiClient.getSinglePost(ApiEndpoints.employee(id));
      if (data == null) {
        throw Exception('Can Not Find Employee By Id: $id');
      }
      return Right(EmployeeModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeModel>>> getActiveEmployees() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.employees);
      final employees = list
          .map((e) => EmployeeModel.fromMap(e))
          .where((e) => e.isActive)
          .toList();
      return Right(employees);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> create(EmployeeEntity entity) async {
    try {
      final data = await _apiClient.createPost(
        endPoint: ApiEndpoints.employees,
        data: EmployeeModel.fromEntity(entity).toMap(removeId: true),
      );
      if (data == null) {
        throw Exception('Data Can Not Be Null to Create Post.');
      }
      return Right(EmployeeModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(EmployeeEntity entity) async {
    try {
      await _apiClient.updatePost(
        endPoint: ApiEndpoints.employee(entity.uid),
        data: EmployeeModel.fromEntity(entity).toMap(removeId: true),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStatus(
    int employeeId,
    bool isActive,
  ) async {
    try {
      await _apiClient.updatePost(
        endPoint: ApiEndpoints.employee(employeeId),
        data: {'is_active': isActive},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _apiClient.deletePost(endPoint: ApiEndpoints.employee(id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeModel?>> getEmployeeByQuery({
    String? employeeId,
    int? cardNo,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (cardNo != null) queryParams['card_no'] = cardNo;
      final response = await _apiClient.get(
        ApiEndpoints.employeeFind,
        queryParameters: queryParams,
      );
      if (response.data == null) return const Right(null);
      final data = response.data as Map<String, dynamic>;
      return Right(EmployeeModel.fromMap(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return const Right(null);
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeModel>> getEmployeeWithShift(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.employeeWithShift(id));
      final data = response.data as Map<String, dynamic>;
      return Right(EmployeeModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeSummaryModel>> getEmployeeSummary(
    int id,
  ) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.employeeSummary(id));
      final data = response.data as Map<String, dynamic>;
      return Right(EmployeeSummaryModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> importEmployeesFromCsv(
    String csvContent,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.employeeImportCsv,
        data: {'csv_content': csvContent},
      );
      final data = response.data as Map<String, dynamic>;
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeFingerprintModel>>> getFingerprints(
    int employeeId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.employeeFingerprints(employeeId),
      );
      final list = response.data as List<dynamic>;
      final fps = list
          .map(
            (e) => EmployeeFingerprintModel.fromMap(e as Map<String, dynamic>),
          )
          .toList();
      return Right(fps);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, EmployeeFingerprintModel>> addFingerprint(
    EmployeeFingerprintEntity entity,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.employeeFingerprints(entity.employeeId),
        data: EmployeeFingerprintModel.fromEntity(entity).toMap(removeId: true),
      );
      final data = response.data as Map<String, dynamic>;
      return Right(EmployeeFingerprintModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFingerprint(
    int employeeId,
    int fingerprintId,
  ) async {
    try {
      await _apiClient.deletePost(
        endPoint: ApiEndpoints.employeeFingerprintDelete(employeeId, fingerprintId),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, FingerprintSearchResult>> searchEmployeeByFingerprint(
    String biometric,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.employeeSearchByFingerprint,
        data: {'biometric': biometric},
      );
      final data = response.data as Map<String, dynamic>;
      return Right(FingerprintSearchResult.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
