import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../../features/auth/domain/entities/auth_user_info.dart';

class UserSession {
  AuthUserInfo? _currentUser;

  UserSession([this._currentUser]);

  AuthUserInfo? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get token => _currentUser?.token;
  int? get userId => _currentUser?.id;
  String? get username => _currentUser?.username;
  UserRole? get role => _currentUser?.role;
  int? get employeeId => _currentUser?.employeeId;

  String? get refreshToken => _currentUser?.refreshToken;

  Future<void> setSession(AuthUserInfo user) async {
    _currentUser = user;
  }

  Future<void> clearSession() async {
    _currentUser = null;
  }

  void updateTokens(String accessToken, String refreshToken) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        token: accessToken,
        refreshToken: refreshToken,
      );
    }
  }
}
