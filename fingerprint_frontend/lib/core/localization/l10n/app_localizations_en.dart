// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ProPlus Attendance Management System';

  @override
  String get fingerprintSystem => 'Fingerprint Management System';

  @override
  String get login => 'Login';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginToContinue => 'Please login to continue';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to logout?';

  @override
  String get username => 'Username';

  @override
  String get usernameRequired => 'Username is required';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get invalidCredentials =>
      'Invalid credentials or account is not active';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String changePasswordFor(String username) {
    return 'Change password for user: $username';
  }

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceDesc => 'Customize the application interface colors';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get employees => 'Employees';

  @override
  String get attendance => 'Attendance';

  @override
  String get attendanceManagementSystem => 'Attendance Management System';

  @override
  String get reports => 'Reports';

  @override
  String get system => 'System';

  @override
  String get usersManagement => 'Users Management';

  @override
  String get addUser => 'Add User';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc => 'Alert and notification settings';

  @override
  String get about => 'About';

  @override
  String get aboutDesc => 'ProPlus Attendance Management System v1.0.0';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get role => 'Role';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleHR => 'HR';

  @override
  String get roleViewer => 'Viewer';

  @override
  String get users => 'Users';

  @override
  String get noUsers => 'No users found';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete the user';

  @override
  String confirmDeleteUser(String username) {
    return 'Are you sure you want to delete user \"$username\"?';
  }

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get userCreated => 'User created successfully';

  @override
  String get userUpdated => 'User updated successfully';

  @override
  String get userDeleted => 'User deleted successfully';

  @override
  String get statusUpdated => 'Status updated successfully';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get addNew => 'Add';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get reload => 'Reload';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get cannotDisableCurrentUser => 'Cannot disable current user';

  @override
  String get cannotEditCurrentUser => 'Cannot edit current user';

  @override
  String get cannotDeleteCurrentUser => 'Cannot delete current user';

  @override
  String get editUserDataPermissions => 'Edit user data and permissions';

  @override
  String get addUserDataPrompt => 'Enter user data to add to the system';

  @override
  String get fullName => 'Full Name';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get employeeUserId => 'Employee ID (UserId)';

  @override
  String get employeeUserIdHint => 'Enter employee ID';

  @override
  String get generateUniqueId => 'Generate Unique ID';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get department => 'Department';

  @override
  String get position => 'Position';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get hireDate => 'Hire Date';

  @override
  String get address => 'Address';

  @override
  String get fingerPrint => 'Fingerprint';

  @override
  String get search => 'Search';

  @override
  String get searchByNameOrCode => 'Search by name, ID or card...';

  @override
  String get all => 'All';

  @override
  String get group => 'Group';

  @override
  String get importCSV => 'Import CSV';

  @override
  String get addNewEmployee => 'Add New Employee';

  @override
  String get code => 'Code';

  @override
  String get name => 'Name';

  @override
  String get card => 'Card';

  @override
  String get cardNo => 'Card Number (CardNo)';

  @override
  String get profile => 'Profile';

  @override
  String get manageFingerprints => 'Manage Fingerprints';

  @override
  String manageFingerprintsFor(String name) {
    return 'Manage Fingerprints - $name';
  }

  @override
  String employeeImportResult(int created, int updated) {
    return 'Added $created and updated $updated';
  }

  @override
  String employeeImportResultWithErrors(int created, int updated, int errors) {
    return 'Added $created and updated $updated ($errors errors)';
  }

  @override
  String confirmDeleteEmployee(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get noRecordsFound => 'No records found';

  @override
  String get noEmployees => 'No employees found';

  @override
  String get withoutShift => 'Without Shift';

  @override
  String get statsSummary => 'Statistics Summary';

  @override
  String get workHours => 'Work Hours';

  @override
  String get lateTime => 'Late Time';

  @override
  String get overtime => 'Overtime';

  @override
  String get fingerprints => 'Fingerprints';

  @override
  String get fingerprintNumber => 'Finger Number';

  @override
  String get biometricTextHint => 'Enter biometric fingerprint text...';

  @override
  String get searchByFingerprint => 'Search by fingerprint...';

  @override
  String get confirmDeleteFingerprint =>
      'Are you sure you want to delete this fingerprint?';

  @override
  String get retry => 'Retry';

  @override
  String get overview => 'Attendance System Overview';

  @override
  String activeEmployees(int count) {
    return '$count Active';
  }

  @override
  String get shifts => 'Shifts';

  @override
  String get devices => 'Devices';

  @override
  String get mostAbsent => 'Most Absent';

  @override
  String hoursAbbreviation(double hours) {
    return '${hours}h';
  }

  @override
  String get mostPresent => 'Most Present';

  @override
  String get mostLate => 'Most Late';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String get noData => 'No Data';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String get noActivitiesToday => 'No activities today';

  @override
  String get unknownFingerprint => 'Unknown Fingerprint';

  @override
  String get unlinked => 'Unlinked';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get lateStatus => 'Late';

  @override
  String get rawFingerprints => 'Raw Fingerprints';

  @override
  String get clearDateFilter => 'Clear Date Filter';

  @override
  String get allEmployees => 'All Employees';

  @override
  String get unknownOnly => 'Unknown Only';

  @override
  String get addManualAttendance => 'Add Manual Attendance';

  @override
  String get noRawFingerprints => 'No Raw Fingerprints';

  @override
  String get employee => 'Employee';

  @override
  String get dateTime => 'Date Time';

  @override
  String get device => 'Device';

  @override
  String get action => 'Action';

  @override
  String unknownWithId(int id) {
    return 'Unknown (ID: $id)';
  }

  @override
  String get linkToEmployee => 'Link to Employee';

  @override
  String get addManualFingerprint => 'Add Manual Fingerprint';

  @override
  String get selectEmployeeData => 'Select Employee Data';

  @override
  String employeeNameIdFormat(String name, String id) {
    return '$name (ID: $id)';
  }

  @override
  String get errorFetchingEmployees => 'Error fetching employees';

  @override
  String get fingerprintTime => 'Fingerprint Time';

  @override
  String get linkFingerprintToEmployee => 'Link Fingerprint to Employee';

  @override
  String get selectEmployee => 'Select Employee';

  @override
  String get link => 'Link';

  @override
  String get fromDate => 'From Date';

  @override
  String get toDate => 'To Date';

  @override
  String get refresh => 'Refresh';

  @override
  String get excel => 'Excel';

  @override
  String get pdf => 'PDF';

  @override
  String get reportExported => 'Report exported successfully';

  @override
  String get tableNo => 'No.';

  @override
  String get employeeName => 'Employee Name';

  @override
  String get shiftLabel => 'Shift';

  @override
  String get dateLabel => 'Date';

  @override
  String get firstFingerprint => 'First Fingerprint';

  @override
  String get lastFingerprint => 'Last Fingerprint';

  @override
  String get totalHours => 'Total Hours';

  @override
  String get fingerprintCount => 'Fingerprint Count';

  @override
  String totalAttendanceDays(int count) {
    return 'Total Attendance Days: $count';
  }

  @override
  String totalHoursSummary(String hours) {
    return 'Total Hours: $hours';
  }

  @override
  String get dash => '---';

  @override
  String get rawFingerprintRecords => 'Raw Fingerprint Records';

  @override
  String get employeeData => 'Employee Data';

  @override
  String get employeeCode => 'Employee Code';

  @override
  String get attendanceStatus => 'Attendance Status';

  @override
  String get shiftData => 'Shift Data';

  @override
  String get attendanceTime => 'Attendance Time';

  @override
  String get departureTime => 'Departure Time';

  @override
  String errorLoadingRecords(String error) {
    return 'Failed to load records: $error';
  }

  @override
  String get noRecordsForEmployee =>
      'No fingerprint records for this employee on this date';

  @override
  String get attendanceReport => 'Attendance Report';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get selectReportType => 'Select report type and press search';

  @override
  String currencyFormat(String amount) {
    return '$amount SAR';
  }

  @override
  String get addDevice => 'Add Device';

  @override
  String get deviceName => 'Device Name';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get port => 'Port';

  @override
  String get deviceType => 'Device Type';

  @override
  String get noDevices => 'No Devices';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get lastSync => 'Last Sync';

  @override
  String get notSynced => 'Not Synced';

  @override
  String get syncData => 'Sync Data';

  @override
  String get deviceId => 'Device ID';

  @override
  String get lastRequestDate => 'Last Request Date';

  @override
  String get noRequestMade => 'No request made';

  @override
  String get firmwareVersion => 'Firmware Version';

  @override
  String get notAvailable => 'N/A';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get fetchProperties => 'Fetch Properties';

  @override
  String get deviceNameRequired => 'Device name is required';

  @override
  String confirmDeleteDevice(String name) {
    return 'Are you sure you want to delete device \"$name\"?';
  }

  @override
  String get deviceManagement => 'Fingerprint Device Management';

  @override
  String get deviceConnectedSuccess => 'Device connected successfully';

  @override
  String get manageDevice => 'Manage Device';

  @override
  String get propertiesTab => 'Properties & Attributes';

  @override
  String get employeesTab => 'Employees';

  @override
  String get fingerprintsTab => 'Fingerprints';

  @override
  String get attendanceTab => 'Attendance';

  @override
  String get liveCaptureTab => 'Live Capture';

  @override
  String employeeDetails(String name) {
    return 'Employee Details: $name';
  }

  @override
  String get internalId => 'Internal ID';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get privilege => 'Privilege';

  @override
  String get privilegeManager => 'Manager';

  @override
  String get privilegeSupervisor => 'General Supervisor';

  @override
  String get privilegeEnroller => 'Enroller';

  @override
  String get privilegeEmployee => 'Employee';

  @override
  String get knownEmployees => 'Known Employees';

  @override
  String get addEmployee => 'Add Employee';

  @override
  String get sync => 'Sync';

  @override
  String get download => 'Download';

  @override
  String get loading => 'Loading...';

  @override
  String get noTemplates => 'No Fingerprints Registered';

  @override
  String get valid => 'Valid';

  @override
  String get invalid => 'Invalid';

  @override
  String get size => 'Size';

  @override
  String get flag => 'Flag';

  @override
  String get stateLabel => 'State';

  @override
  String get typeLabel => 'Type';

  @override
  String get dateTimeLabel => 'Date & Time';

  @override
  String get employeeCodeLabel => 'Employee Code';

  @override
  String get stop => 'Stop';

  @override
  String get startListening => 'Start Listening';

  @override
  String get waitingForFingerprints => 'Waiting for fingerprints...';

  @override
  String get deviceActivityReport => 'Device Fingerprint Density Report';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featureUnderDevelopment =>
      'This feature is under development and will be available soon';

  @override
  String get shiftManagement => 'Shift Management';

  @override
  String get addShift => 'Add Shift';

  @override
  String get shiftName => 'Shift Name';

  @override
  String get shiftNameRequired => 'Shift name is required';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get nightShift => 'Night';

  @override
  String get overtimeShift => 'Overtime';

  @override
  String get holiday => 'Holiday';

  @override
  String get noShifts => 'No Shifts';

  @override
  String get editShift => 'Edit Shift';

  @override
  String get addNewShift => 'Add New Shift';

  @override
  String get editShiftData => 'Edit shift data';

  @override
  String get addShiftData => 'Enter shift data to add';

  @override
  String get earlyEntryBefore => 'Early Entry (Before)';

  @override
  String get lateEntryAfter => 'Late Entry (After)';

  @override
  String get earlyExitBefore => 'Early Exit (Before)';

  @override
  String get lateExitAfter => 'Late Exit (After)';

  @override
  String get maxAttendanceTime => 'Max Attendance Time';

  @override
  String get saving => 'Saving...';

  @override
  String confirmDeleteShift(String name) {
    return 'Are you sure you want to delete shift \"$name\"?';
  }

  @override
  String get systemDashboard => 'System Dashboard';

  @override
  String get systemSettingsDescription =>
      'Manage system settings and constants';

  @override
  String get shiftManagementCardDesc =>
      'Manage shift times, grace periods, and work days';

  @override
  String get deviceManagementCardDesc =>
      'Manage fingerprint devices, status, and sync';

  @override
  String get newLabel => 'New';

  @override
  String get existingLabel => 'Existing';

  @override
  String selectedCountFormat(int selected, int total) {
    return 'Selected: $selected of $total';
  }

  @override
  String get editBeforeSync => 'Edit employee data before sync';

  @override
  String syncCompleteWithErrors(
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return 'Sync complete: $created added, $updated updated, $skipped skipped, $failed failed';
  }

  @override
  String syncCompleteSuccess(int created, int updated, int skipped) {
    return 'Sync completed successfully: $created added, $updated updated, $skipped skipped';
  }

  @override
  String get stateEntry => 'Entry';

  @override
  String get stateExit => 'Exit';

  @override
  String get stateBreakStart => 'Break Start';

  @override
  String get stateBreakEnd => 'Break End';

  @override
  String get stateOvertimeIn => 'Overtime In';

  @override
  String get stateOvertimeOut => 'Overtime Out';

  @override
  String get typeFingerprint => 'Fingerprint';

  @override
  String get typePassword => 'Password';

  @override
  String get typeCard => 'Card';

  @override
  String get typeFingerprintPassword => 'Fingerprint+Password';

  @override
  String get syncAttendanceRecords => 'Sync Attendance Records';

  @override
  String recordsInDevice(int count) {
    return 'Records in device: $count';
  }

  @override
  String get inDatabase => 'In Database';

  @override
  String get notFoundInDb => '--- (Not Found)';

  @override
  String get noEmployee => 'No Employee';

  @override
  String syncResultSummary(int selectedCount, int noEmployeeCount) {
    return 'Selected: $selectedCount new, $noEmployeeCount without employee';
  }

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncAttendanceBtn => 'Sync Attendance Data';

  @override
  String get recordsWithoutEmployeeWarning =>
      'Records without employee (ID not found in database) will not be synced';

  @override
  String syncAttendanceResult(int created, int skipped, int failed) {
    return 'Sync result: $created added, $skipped skipped, $failed failed';
  }

  @override
  String syncAttendanceResultSuccess(int created, int skipped) {
    return 'Sync completed: $created new records, $skipped skipped';
  }

  @override
  String get proPlusAttendance => 'Pro-Plus Attendance';

  @override
  String get splashInitializing => 'Initializing application...';

  @override
  String get splashStartingPostgres => 'Starting database...';

  @override
  String get splashStartingBackend => 'Starting server...';

  @override
  String get splashReady => 'Application ready';

  @override
  String get splashError => 'An error occurred during initialization';

  @override
  String get splashRetry => 'Retry';
}
