import 'package:flutter/foundation.dart';

import '../entities/user_entity.dart';
import '../enums/user_role_enum.dart';

/// Model representation of `UserEntity` for data layer conversions.
final class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    super.passwordHash,
    required super.role,
    super.employeeId,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int,
      username: map['username'] as String? ?? '',
      passwordHash: map['password_hash'] as String?,
      role: UserRole.of(map['role'] as String? ?? 'viewer'),
      employeeId: map['employee_id'] as int?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      passwordHash: entity.passwordHash,
      role: entity.role,
      employeeId: entity.employeeId,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      username: username,
      passwordHash: passwordHash,
      role: role,
      employeeId: employeeId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId) 'id': id,
      'username': username,
      'password_hash': passwordHash,
      'role': role.name,
      'employee_id': employeeId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    UserRole? role,
    int? employeeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
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
