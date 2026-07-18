import 'app_enum.dart';

/// Employee role enum with values matching device privilege codes.
sealed class EmployeeRole extends AppEnum {
  const EmployeeRole();

  static const user = _User._();
  static const register = _Register._();
  static const superAdmin = _SuperAdmin._();
  static const admin = _Admin._();

  static List<EmployeeRole> get values => [user, register, superAdmin, admin];

  static EmployeeRole of(String? name) {
    final key = (name ?? '').toLowerCase();
    return values.firstWhere(
      (e) => e.name.toLowerCase() == key,
      orElse: () => user,
    );
  }

  static EmployeeRole fromPrivilege(int privilege) {
    return switch (privilege) {
      14 => admin,
      6 => superAdmin,
      2 => register,
      _ => user,
    };
  }
}

final class _User extends EmployeeRole {
  const _User._();

  @override
  String get name => 'user';

  @override
  int get index => 0;

  @override
  String displayName(dynamic localization) => 'مستخدم';
}

final class _Register extends EmployeeRole {
  const _Register._();

  @override
  String get name => 'register';

  @override
  int get index => 2;

  @override
  String displayName(dynamic localization) => 'مسجل';
}

final class _SuperAdmin extends EmployeeRole {
  const _SuperAdmin._();

  @override
  String get name => 'super_admin';

  @override
  int get index => 6;

  @override
  String displayName(dynamic localization) => 'مشرف عام';
}

final class _Admin extends EmployeeRole {
  const _Admin._();

  @override
  String get name => 'admin';

  @override
  int get index => 14;

  @override
  String displayName(dynamic localization) => 'مدير';
}
