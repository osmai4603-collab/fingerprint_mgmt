import 'package:dartz/dartz.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/features/auth/domain/entities/auth_user_info.dart';

abstract class UsersRepository extends Repository<UserEntity, int> {
  Future<Either<Failure, AuthUserInfo>> login(String username, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> changePassword(int userId, String newPassword);
  Future<Either<Failure, void>> toggleStatus(int userId, bool isActive);
}
