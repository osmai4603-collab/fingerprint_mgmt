import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_records_repository.dart';

class AttendanceRecordsRepositoryImpl implements AttendanceRecordsRepository {
  final ApiClient _apiClient;

  AttendanceRecordsRepositoryImpl(this._apiClient);

  Map<String, dynamic> _query({required DateTime from, required DateTime to, int? employeeId}) {
    final params = <String, dynamic>{
      'from': formatDate(from),
      'to': formatDate(to),
    };
    if (employeeId != null) {
      params['employee_id'] = employeeId;
    }
    return params;
  }

  Future<Either<Failure, List<T>>> _fetchReport<T>({
    required String endpoint,
    required DateTime from,
    required DateTime to,
    int? employeeId,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    try {
      final list = await _apiClient.getPosts(
        endpoint,
        queryParameters: _query(from: from, to: to, employeeId: employeeId),
      );
      return Right(list.map(fromMap).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['detail'] ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmployeeFingerprintReport>>> getEmployeeFingerprintReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsFingerprint,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: EmployeeFingerprintReport.fromMap,
      );

  @override
  Future<Either<Failure, List<AttendanceSummaryReport>>> getAttendanceSummaryReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsSummary,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: AttendanceSummaryReport.fromMap,
      );

  @override
  Future<Either<Failure, List<DetailedDailyReport>>> getDetailedDailyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsDetailed,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: DetailedDailyReport.fromMap,
      );

  @override
  Future<Either<Failure, List<DetailedDailyReport>>> getAttendanceOnlyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsAttendanceOnly,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: DetailedDailyReport.fromMap,
      );

  @override
  Future<Either<Failure, List<DetailedDailyReport>>> getAbsenceOnlyReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsAbsenceOnly,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: DetailedDailyReport.fromMap,
      );

  @override
  Future<Either<Failure, List<DetailedDailyReport>>> getLateAttendanceReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsLate,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: DetailedDailyReport.fromMap,
      );

  @override
  Future<Either<Failure, List<DetailedDailyReport>>> getAbsenceWithDeductionsReport({
    required DateTime from,
    required DateTime to,
    int? employeeId,
  }) =>
      _fetchReport(
        endpoint: ApiEndpoints.reportsAbsenceDeductions,
        from: from,
        to: to,
        employeeId: employeeId,
        fromMap: DetailedDailyReport.fromMap,
      );
}
