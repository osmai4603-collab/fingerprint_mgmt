import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_event.dart';
import 'users_state.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/auth_repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final AuthRepository _authRepository;

  UsersBloc(this._authRepository) : super(const UsersInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<CreateUserEvent>(_onCreateUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ToggleUserStatusEvent>(_onToggleStatus);
    on<DeleteUserEvent>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final result = await _authRepository.get();
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users.cast())),
    );
  }

  Future<void> _onCreateUser(
    CreateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final result = await _authRepository.create(event.user);
    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      emit(const UsersOperationSuccess('تم إنشاء المستخدم بنجاح'));
      add(const LoadUsersEvent());
    });
  }

  Future<void> _onUpdateUser(
    UpdateUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final entity = UserModel(
      id: event.id,
      username: event.username,
      role: UserRole.of(event.role ?? 'viewer'),
      employeeId: event.employeeId,
      isActive: event.isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await _authRepository.update(entity);
    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      emit(const UsersOperationSuccess('تم تحديث المستخدم بنجاح'));
      add(const LoadUsersEvent());
    });
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final result = await _authRepository.changePassword(
      event.userId,
      event.newPassword,
    );
    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      emit(const UsersOperationSuccess('تم تغيير كلمة المرور بنجاح'));
      add(const LoadUsersEvent());
    });
  }

  Future<void> _onToggleStatus(
    ToggleUserStatusEvent event,
    Emitter<UsersState> emit,
  ) async {
    final result = await _authRepository.toggleStatus(
      event.userId,
      event.isActive,
    );
    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      emit(const UsersOperationSuccess('تم تحديث الحالة بنجاح'));
      add(const LoadUsersEvent());
    });
  }

  Future<void> _onDeleteUser(
    DeleteUserEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    final result = await _authRepository.delete(event.userId);
    result.fold((failure) => emit(UsersError(failure.message)), (_) {
      emit(const UsersOperationSuccess('تم حذف المستخدم بنجاح'));
      add(const LoadUsersEvent());
    });
  }
}
