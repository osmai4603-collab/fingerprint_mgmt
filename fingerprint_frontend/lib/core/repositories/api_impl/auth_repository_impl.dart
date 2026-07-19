import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/features/auth/domain/entities/auth_user_info.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, AuthUserInfo>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: {'username': username, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      final token = data['token'] as String;

      final authUser = AuthUserInfo(
        id: userData['id'] as int,
        username: userData['username'] as String,
        role: UserRole.of(userData['role'] as String? ?? 'viewer'),
        token: token,
        employeeId: userData['employee_id'] as int?,
      );

      return Right(authUser);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        return Left(ServerFailure('بيانات الدخول غير صحيحة أو الحساب غير نشط'));
      }
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.authLogout);
    } catch (_) {}
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<UserEntity>>> get() async {
    try {
      final list = await _apiClient.getPosts(ApiEndpoints.authGetUsers);
      final users = list.map(UserModel.fromMap).toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(ServerFailure(e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getById(int id) async {
    return Left(ServerFailure('ال backend لا يدعم جلب مستخدم واحد'));
  }

  @override
  Future<Either<Failure, UserEntity>> create(UserEntity entity) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.authSignup,
        data: {
          'username': entity.username,
          'password': entity.passwordHash ?? '',
          'role': entity.role.name,
          if (entity.employeeId != null) 'employee_id': entity.employeeId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Right(UserModel.fromMap(data));
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      return Left(ServerFailure(detail ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> update(UserEntity entity) async {
    try {
      final body = <String, dynamic>{
        'username': entity.username,
        'role': entity.role.name,
        'is_active': entity.isActive,
      };
      if (entity.employeeId != null) {
        body['employee_id'] = entity.employeeId;
      }
      await _apiClient.put(ApiEndpoints.authUser(entity.id), data: body);
      return const Right(null);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      return Left(ServerFailure(detail ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.authUser(id));
      return const Right(null);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      return Left(ServerFailure(detail ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword(
    int userId,
    String newPassword,
  ) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.authUserPassword(userId),
        data: {'new_password': newPassword},
      );
      return const Right(null);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      return Left(ServerFailure(detail ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleStatus(int userId, bool isActive) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.authUserStatus(userId),
        data: {'is_active': isActive},
      );
      return const Right(null);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail']?.toString();
      return Left(ServerFailure(detail ?? e.toString()));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
