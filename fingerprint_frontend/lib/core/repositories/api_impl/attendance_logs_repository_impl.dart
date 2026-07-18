import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';

class AttendanceLogsRepositoryImpl implements AttendanceLogsRepository {
  final ApiClient _apiClient;

  AttendanceLogsRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<AttendanceLogEntity>>> get() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.attendanceLogs);
      return Right(list.map((e) => AttendanceLogModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, AttendanceLogEntity>> getById(int id) async {
    try {
      final data = await _apiClient.getSinglePost(
        '${ApiEndpoints.attendanceLogs}/$id',
      );
      if (data == null) {
        throw Exception('Can Not Find Attendance Log By Id: $id');
      }
      return Right(AttendanceLogModel.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, AttendanceLogEntity>> create(
    AttendanceLogEntity entity,
  ) async {
    try {
      final data = await _apiClient.createPost(
        endPoint: ApiEndpoints.attendanceLogs,
        data: AttendanceLogModel.fromEntity(entity).toMap(removeId: true),
      );
      if (data == null) {
        throw Exception('Data Can Not Be Null to Create Post.');
      }
      return Right(AttendanceLogModel.fromJson(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(AttendanceLogEntity entity) async {
    try {
      await _apiClient.updatePost(
        endPoint: '${ApiEndpoints.attendanceLogs}/${entity.id}',
        data: AttendanceLogModel.fromEntity(entity).toMap(removeId: true),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _apiClient.deletePost(
        endPoint: '${ApiEndpoints.attendanceLogs}/$id',
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceLogModel>>> getAttendanceLogs({
    int? employeeId,
    DateTime? fromDate,
    DateTime? toDate,
    bool unrecognizedOnly = false,
  }) async {
    try {
      if (unrecognizedOnly) {
        final list = await _apiClient.getPosts(
          ApiEndpoints.attendanceUnrecognized,
        );
        return Right(list.map(AttendanceLogModel.fromJson).toList());
      } else {
        final queryParams = <String, dynamic>{};
        if (employeeId != null) {
          queryParams['employee_id'] = employeeId;
        }
        if (fromDate != null) {
          queryParams['from'] = formatDate(fromDate);
        }
        if (toDate != null) {
          queryParams['to'] = formatDate(toDate);
        }
        final list = await _apiClient.getPosts(
          ApiEndpoints.attendanceLogs,
          queryParameters: queryParams,
        );
        return Right(list.map(AttendanceLogModel.fromJson).toList());
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> linkLog(int logId, int employeeId) async {
    try {
      await _apiClient.updatePost(
        endPoint: ApiEndpoints.attendanceLinkLog(logId),
        data: {'employee_id': employeeId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addManualPunch(
    int employeeId,
    DateTime punchTime, {
    int? deviceId,
  }) async {
    try {
      final data = <String, dynamic>{
        'employee_id': employeeId,
        'punch_time': punchTime.toIso8601String(),
      };
      if (deviceId != null) {
        data['device_id'] = deviceId;
      }
      await _apiClient.post(ApiEndpoints.attendanceManualPunch, data: data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DeviceAttendanceLog>>> getDeviceAttendance(
    int deviceId, {
    DateTime? startDate,
  }) async {
    try {
      final logs = await _apiClient.getPosts(
        '${ApiEndpoints.devices}/$deviceId/attendance',
        queryParameters: startDate != null
            ? {'start_date': formatDate(startDate)}
            : null,
      );
      return Right(logs.map((e) => DeviceAttendanceLog.fromMap(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncDeviceData(
    int deviceId,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.devices}/$deviceId/sync',
      );
      final data = response.data as Map<String, dynamic>;
      return Right(data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
