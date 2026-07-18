import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class AuthUserInfo extends Equatable {
  final int id;
  final String username;
  final UserRole role;
  final String token;
  final String? refreshToken;
  final int? employeeId;

  const AuthUserInfo({
    required this.id,
    required this.username,
    required this.role,
    required this.token,
    this.refreshToken,
    this.employeeId,
  });

  AuthUserInfo copyWith({
    int? id,
    String? username,
    UserRole? role,
    String? token,
    String? refreshToken,
    int? employeeId,
  }) {
    return AuthUserInfo(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      employeeId: employeeId ?? this.employeeId,
    );
  }

  @override
  List<Object?> get props => [id, username, role.name, token, refreshToken, employeeId];
}
