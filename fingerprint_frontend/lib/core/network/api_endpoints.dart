class ApiEndpoints {
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';
  static const String authSignup = '/api/auth/signup';
  static const String authGetUsers = '/api/auth/getusers';
  static String authUser(int id) => '/api/auth/users/$id';
  static String authUserPassword(int id) => '/api/auth/users/$id/password';
  static String authUserStatus(int id) => '/api/auth/users/$id/status';
 
  static const String employees = '/api/employees/';
  static String employee(int id) => '/api/employees/$id';
  static String employeeWithShift(int id) => '/api/employees/$id/with-shift';
  static String employeeSummary(int id) => '/api/employees/$id/summary';
  static String employeeFingerprints(int id) => '/api/employees/$id/fingerprints';
  static String employeeFingerprintDelete(int empId, int fpId) => '/api/employees/$empId/fingerprints/$fpId';
  static const String employeeFind = '/api/employees/find';
  static const String employeeImportCsv = '/api/employees/import-csv';
  static const String employeeSearchByFingerprint = '/api/employees/search-by-fingerprint';

  static const String attendanceLogs = '/api/attendance/logs';
  static const String attendanceUnrecognized = '/api/attendance/unrecognized';
  static String attendanceLinkLog(int logId) => '/api/attendance/logs/$logId/link';
  static const String attendanceManualPunch = '/api/attendance/manual-punch';
  static String attendanceLogItem(int id) => '/api/attendance/logs/$id';

  static const String reportsFingerprint = '/api/reports/fingerprint';
  static const String reportsSummary = '/api/reports/summary';
  static const String reportsDetailed = '/api/reports/detailed';
  static const String reportsAttendanceOnly = '/api/reports/attendance-only';
  static const String reportsAbsenceOnly = '/api/reports/absence-only';
  static const String reportsLate = '/api/reports/late';
  static const String reportsAbsenceDeductions = '/api/reports/absence-deductions';

  static const String shifts = '/api/shifts/';
  static String shift(int id) => '/api/shifts/$id';

  static const String devices = '/api/devices/';
  static String device(int id) => '/api/devices/$id';
  static String deviceStatus(int id) => '/api/devices/$id/status';
  static String deviceUsers(int id) => '/api/devices/$id/users';
  static String deviceUserDelete(int id, int uid) => '/api/devices/$id/users/$uid';
  static String deviceTemplates(int id) => '/api/devices/$id/templates';
  static String deviceTemplateDelete(int id, int uid) => '/api/devices/$id/templates/$uid';
  static String deviceCommand(int id) => '/api/devices/$id/command';

}
