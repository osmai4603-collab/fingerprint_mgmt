import 'app_enum.dart';

sealed class UserRole extends AppEnum {
  const UserRole();

  static const admin = _Admin._();
  static const hr = _HR._();
  static const viewer = _Viewer._();

  static List<UserRole> get values => [admin, hr, viewer];

  static UserRole of(String? name) {
    final key = (name ?? '').toLowerCase();
    return values.firstWhere(
      (e) => e.name.toLowerCase() == key,
      orElse: () => viewer,
    );
  }
}

final class _Admin extends UserRole {
  const _Admin._();

  @override
  String get name => 'admin';

  @override
  int get index => 0;

  @override
  String displayName(dynamic localization) =>
      localization?.roleAdmin ?? 'مسؤول';
}

final class _HR extends UserRole {
  const _HR._();

  @override
  String get name => 'hr';

  @override
  int get index => 1;

  @override
  String displayName(dynamic localization) =>
      localization?.roleHR ?? 'موارد بشرية';
}

final class _Viewer extends UserRole {
  const _Viewer._();

  @override
  String get name => 'viewer';

  @override
  int get index => 2;

  @override
  String displayName(dynamic localization) =>
      localization?.roleViewer ?? 'مشاهد';
}
