import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class UsersState extends Equatable {
  const UsersState();
}

class UsersInitial extends UsersState {
  const UsersInitial();

  @override
  List<Object?> get props => [];
}

class UsersLoading extends UsersState {
  const UsersLoading();

  @override
  List<Object?> get props => [];
}

class UsersLoaded extends UsersState {
  final List<UserModel> users;

  const UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UsersOperationSuccess extends UsersState {
  final String message;

  const UsersOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UsersError extends UsersState {
  final String message;

  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}
