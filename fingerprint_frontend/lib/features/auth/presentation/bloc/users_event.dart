import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
}

class LoadUsersEvent extends UsersEvent {
  const LoadUsersEvent();

  @override
  List<Object?> get props => [];
}

class CreateUserEvent extends UsersEvent {
  final UserEntity user;

  const CreateUserEvent({required this.user});

  @override
  List<Object?> get props => [user];
}

class UpdateUserEvent extends UsersEvent {
  final int id;
  final String username;
  final String? role;
  final int? employeeId;
  final bool isActive;

  const UpdateUserEvent({
    required this.id,
    required this.username,
    this.role,
    this.employeeId,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, username, role ?? '', employeeId, isActive];
}

class ChangePasswordEvent extends UsersEvent {
  final int userId;
  final String newPassword;

  const ChangePasswordEvent({
    required this.userId,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, newPassword];
}

class ToggleUserStatusEvent extends UsersEvent {
  final int userId;
  final bool isActive;

  const ToggleUserStatusEvent({
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, isActive];
}

class DeleteUserEvent extends UsersEvent {
  final int userId;

  const DeleteUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
