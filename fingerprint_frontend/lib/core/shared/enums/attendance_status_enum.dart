import 'app_enum.dart';

/// Attendance status enum with four states: in, out, break_in, break_out.
sealed class AttendanceStatus extends AppEnum {
  const AttendanceStatus();

  static const checkIn = _CheckIn._();
  static const checkOut = _CheckOut._();
  static const breakIn = _BreakIn._();
  static const breakOut = _BreakOut._();

  static List<AttendanceStatus> get values => [checkIn, checkOut, breakIn, breakOut];

  static AttendanceStatus of(String? name) {
    final key = (name ?? '').toLowerCase();
    return values.firstWhere(
      (e) => e.name.toLowerCase() == key,
      orElse: () => checkIn,
    );
  }
}

final class _CheckIn extends AttendanceStatus {
  const _CheckIn._();

  @override
  String get name => 'in';

  @override
  int get index => 0;

  @override
  String displayName(dynamic localization) => localization?.attendanceIn ?? 'In';
}

final class _CheckOut extends AttendanceStatus {
  const _CheckOut._();

  @override
  String get name => 'out';

  @override
  int get index => 1;

  @override
  String displayName(dynamic localization) => localization?.attendanceOut ?? 'Out';
}

final class _BreakIn extends AttendanceStatus {
  const _BreakIn._();

  @override
  String get name => 'break_in';

  @override
  int get index => 2;

  @override
  String displayName(dynamic localization) => localization?.attendanceBreakIn ?? 'Break In';
}

final class _BreakOut extends AttendanceStatus {
  const _BreakOut._();

  @override
  String get name => 'break_out';

  @override
  int get index => 3;

  @override
  String displayName(dynamic localization) => localization?.attendanceBreakOut ?? 'Break Out';
}
