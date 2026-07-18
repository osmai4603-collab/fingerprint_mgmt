import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/network/api_client.dart';
import 'package:fingerprint_frontend/core/network/api_endpoints.dart';
import 'package:fingerprint_frontend/features/auth/domain/entities/auth_user_info.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  final ApiClient _apiClient;

  UsersRepositoryImpl(this._apiClient);

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
      debugPrint('Error: $e');
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
    return Left(ServerFailure('ال backend لا يدعم إنشاء مستخدم'));
  }

  @override
  Future<Either<Failure, void>> update(UserEntity entity) async {
    return Left(ServerFailure('ال backend لا يدعم تحديث مستخدم'));
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    return Left(ServerFailure('ال backend لا يدعم حذف المستخدم'));
  }

  @override
  Future<Either<Failure, void>> changePassword(
    int userId,
    String newPassword,
  ) async {
    return Left(ServerFailure('ال backend لا يدعم تغيير كلمة المرور'));
  }

  @override
  Future<Either<Failure, void>> toggleStatus(int userId, bool isActive) async {
    return Left(ServerFailure('ال backend لا يدعم تغيير حالة المستخدم'));
  }
}
