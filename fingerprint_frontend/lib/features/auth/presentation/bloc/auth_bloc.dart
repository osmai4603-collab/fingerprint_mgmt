import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/auth_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/user_session.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future.delayed(
      const Duration(seconds: 2),
    );
    final result = await _authRepository.login(event.username, event.password);
    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      get_it<UserSession>().setSession(user);
      emit(AuthAuthenticated(user));
    });
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    get_it<UserSession>().clearSession();
    emit(const AuthUnauthenticated());
  }
}
