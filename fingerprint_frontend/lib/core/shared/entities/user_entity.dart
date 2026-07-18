import 'package:fingerprint_frontend/core/shared/entities/entity.dart';
import '../enums/user_role_enum.dart';

/// Core user entity with roles and optional linked employee
class UserEntity extends Entity {
  final int id;
  final String username;
  final String? passwordHash;
  final UserRole role;
  final int? employeeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.username,
    this.passwordHash,
    required this.role,
    this.employeeId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    username,
    passwordHash,
    role.name,
    employeeId,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  UserEntity copyWith({
    int? id,
    String? username,
    String? passwordHash,
    UserRole? role,
    int? employeeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      employeeId: employeeId ?? this.employeeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
