import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';

class ShiftsRepositoryImpl implements ShiftsRepository {
  final ApiClient _apiClient;

  ShiftsRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<ShiftEntity>>> get() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.shifts);
      final shifts = list.map((e) => ShiftModel.fromMap(e)).toList();
      return Right(shifts);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, ShiftEntity>> getById(int id) async {
    try {
      final data = await _apiClient.getSinglePost(ApiEndpoints.shift(id));
      if (data == null) {
        throw Exception('Can Not Find Shift By Id: $id');
      }
      return Right(ShiftModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, ShiftEntity>> create(ShiftEntity entity) async {
    try {
      final data = await _apiClient.createPost(
        endPoint: ApiEndpoints.shifts,
        data: ShiftModel.fromEntity(entity).toMap(removeId: true),
      );
      if (data == null) {
        throw Exception('Data Can Not Be Null to Create Post.');
      }
      return Right(ShiftModel.fromMap(data));
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(ShiftEntity entity) async {
    try {
      await _apiClient.updatePost(
        endPoint: ApiEndpoints.shift(entity.id),
        data: ShiftModel.fromEntity(entity).toMap(removeId: true),
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
      await _apiClient.deletePost(endPoint: ApiEndpoints.shift(id));
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
