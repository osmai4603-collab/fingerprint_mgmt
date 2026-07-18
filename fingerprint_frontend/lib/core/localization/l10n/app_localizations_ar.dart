// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام برو-بلس لإدارة الحضور';

  @override
  String get fingerprintSystem => 'نظام إدارة البصمات';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get loginToContinue => 'قم بتسجيل الدخول للمتابعة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get confirmLogoutMessage => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get usernameRequired => 'يرجى إدخال اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  @override
  String get passwordMismatch => 'كلمة المرور غير متطابقة';

  @override
  String get invalidCredentials => 'بيانات الدخول غير صحيحة أو الحساب غير نشط';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String changePasswordFor(String username) {
    return 'تغيير كلمة المرور للمستخدم: $username';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceDesc => 'تخصيص ألوان واجهة التطبيق';

  @override
  String get lightTheme => 'فاتح';

  @override
  String get darkTheme => 'داكن';

  @override
  String get systemTheme => 'نظام';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get home => 'الرئيسية';

  @override
  String get employees => 'الموظفين';

  @override
  String get attendance => 'الحضور والانصراف';

  @override
  String get attendanceManagementSystem => 'نظام إدارة الحضور';

  @override
  String get reports => 'التقارير';

  @override
  String get system => 'النظام';

  @override
  String get usersManagement => 'إدارة المستخدمين';

  @override
  String get addUser => 'إضافة مستخدم';

  @override
  String get editUser => 'تعديل مستخدم';

  @override
  String get deleteUser => 'حذف مستخدم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsDesc => 'إعدادات التنبيهات والإشعارات';

  @override
  String get about => 'حول التطبيق';

  @override
  String get aboutDesc => 'نظام برو-بلس لإدارة الحضور v1.0.0';

  @override
  String get activate => 'تفعيل';

  @override
  String get deactivate => 'تعطيل';

  @override
  String get role => 'الدور';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get roleHR => 'موارد بشرية';

  @override
  String get roleViewer => 'مشاهد';

  @override
  String get users => 'المستخدمون';

  @override
  String get noUsers => 'لا يوجد مستخدمون';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteMessage => 'هل أنت متأكد من حذف المستخدم';

  @override
  String confirmDeleteUser(String username) {
    return 'هل أنت متأكد من حذف المستخدم \"$username\"؟';
  }

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get userCreated => 'تم إنشاء المستخدم بنجاح';

  @override
  String get userUpdated => 'تم تحديث المستخدم بنجاح';

  @override
  String get userDeleted => 'تم حذف المستخدم بنجاح';

  @override
  String get statusUpdated => 'تم تحديث الحالة بنجاح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get addNew => 'إضافة';

  @override
  String get update => 'تحديث';

  @override
  String get delete => 'حذف';

  @override
  String get close => 'إغلاق';

  @override
  String get reload => 'إعادة تحميل';

  @override
  String get status => 'الحالة';

  @override
  String get actions => 'الإجراءات';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get enabled => 'مفعل';

  @override
  String get disabled => 'معطل';

  @override
  String get cannotDisableCurrentUser => 'لا يمكن تعطيل المستخدم الحالي';

  @override
  String get cannotEditCurrentUser => 'لا يمكن تعديل المستخدم الحالي';

  @override
  String get cannotDeleteCurrentUser => 'لا يمكن حذف المستخدم الحالي';

  @override
  String get editUserDataPermissions => 'تعديل بيانات المستخدم وصلاحياته';

  @override
  String get addUserDataPrompt => 'أدخل بيانات المستخدم لإضافته للنظام';

  @override
  String get fullName => 'الاسم';

  @override
  String get employeeId => 'رقم الموظف';

  @override
  String get employeeUserId => 'رقم الموظف (UserId)';

  @override
  String get employeeUserIdHint => 'ادخل رقم الموظف ID';

  @override
  String get generateUniqueId => 'توليد رقم فريد';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get department => 'القسم';

  @override
  String get position => 'المنصب';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get hireDate => 'تاريخ التوظيف';

  @override
  String get address => 'العنوان';

  @override
  String get fingerPrint => 'البصمة';

  @override
  String get search => 'بحث';

  @override
  String get searchByNameOrCode => 'بحث بالاسم أو الرمز أو البطاقة...';

  @override
  String get all => 'الكل';

  @override
  String get group => 'المجموعة';

  @override
  String get importCSV => 'استيراد CSV';

  @override
  String get addNewEmployee => 'إضافة موظف جديد';

  @override
  String get code => 'الرمز';

  @override
  String get name => 'الاسم';

  @override
  String get card => 'البطاقة';

  @override
  String get cardNo => 'رقم البطاقة (CardNo)';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get manageFingerprints => 'إدارة البصمات';

  @override
  String manageFingerprintsFor(String name) {
    return 'إدارة البصمات - $name';
  }

  @override
  String employeeImportResult(int created, int updated) {
    return 'تم إضافة $created وتحديث $updated';
  }

  @override
  String employeeImportResultWithErrors(int created, int updated, int errors) {
    return 'تم إضافة $created وتحديث $updated ($errors أخطاء)';
  }

  @override
  String confirmDeleteEmployee(String name) {
    return 'هل أنت متأكد من حذف $name؟';
  }

  @override
  String get noRecordsFound => 'لا توجد بيانات';

  @override
  String get noEmployees => 'لا يوجد موظفون';

  @override
  String get withoutShift => 'بدون وردية';

  @override
  String get statsSummary => 'ملخص الإحصائيات';

  @override
  String get workHours => 'ساعات العمل';

  @override
  String get lateTime => 'التأخير';

  @override
  String get overtime => 'العمل الإضافي';

  @override
  String get fingerprints => 'البصمات';

  @override
  String get fingerprintNumber => 'رقم الإصبع';

  @override
  String get biometricTextHint => 'أدخل نص البصمة البيومترية...';

  @override
  String get searchByFingerprint => 'بحث بالبصمة...';

  @override
  String get confirmDeleteFingerprint => 'هل أنت متأكد من حذف هذه البصمة؟';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get overview => 'نظرة عامة على نظام الحضور والانصراف';

  @override
  String activeEmployees(int count) {
    return '$count نشط';
  }

  @override
  String get shifts => 'الورديات';

  @override
  String get devices => 'الأجهزة';

  @override
  String get mostAbsent => 'الأكثر غيابا';

  @override
  String hoursAbbreviation(double hours) {
    return '$hours س';
  }

  @override
  String get mostPresent => 'الأكثر حضورا';

  @override
  String get mostLate => 'الأكثر تأخيرا';

  @override
  String timesCount(int count) {
    return '$count مرة';
  }

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get recentActivities => 'آخر النشاطات';

  @override
  String get noActivitiesToday => 'لا توجد نشاطات اليوم';

  @override
  String get unknownFingerprint => 'بصمة غير معروفة';

  @override
  String get unlinked => 'غير مرتبط';

  @override
  String get todaySummary => 'ملخص اليوم';

  @override
  String get present => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get lateStatus => 'متأخر';

  @override
  String get rawFingerprints => 'البصمات الخام';

  @override
  String get clearDateFilter => 'إلغاء فلتر التاريخ';

  @override
  String get allEmployees => 'كل الموظفين';

  @override
  String get unknownOnly => 'غير المعروفة فقط';

  @override
  String get addManualAttendance => 'إضافة حضور يدوي';

  @override
  String get noRawFingerprints => 'لا توجد بصمات خام';

  @override
  String get employee => 'الموظف';

  @override
  String get dateTime => 'وقت البصمة';

  @override
  String get device => 'الجهاز';

  @override
  String get action => 'إجراء';

  @override
  String unknownWithId(int id) {
    return 'غير معروف (ID: $id)';
  }

  @override
  String get linkToEmployee => 'ربط بموظف';

  @override
  String get addManualFingerprint => 'إضافة بصمة يدوية';

  @override
  String get selectEmployeeData => 'حدد بيانات الموظف';

  @override
  String employeeNameIdFormat(String name, String id) {
    return '$name (ID: $id)';
  }

  @override
  String get errorFetchingEmployees => 'خطأ في جلب الموظفين';

  @override
  String get fingerprintTime => 'وقت البصمة';

  @override
  String get linkFingerprintToEmployee => 'ربط بصمة بموظف';

  @override
  String get selectEmployee => 'اختر الموظف';

  @override
  String get link => 'ربط';

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get refresh => 'تحديث';

  @override
  String get excel => 'Excel';

  @override
  String get pdf => 'PDF';

  @override
  String get reportExported => 'تم تصدير التقرير بنجاح';

  @override
  String get tableNo => 'No.';

  @override
  String get employeeName => 'اسم الموظف';

  @override
  String get shiftLabel => 'الوردية';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get firstFingerprint => 'أول بصمة';

  @override
  String get lastFingerprint => 'آخر بصمة';

  @override
  String get totalHours => 'عدد الساعات';

  @override
  String get fingerprintCount => 'عدد البصمات';

  @override
  String totalAttendanceDays(int count) {
    return 'إجمالي أيام الدوام: $count';
  }

  @override
  String totalHoursSummary(String hours) {
    return 'إجمالي الساعات: $hours';
  }

  @override
  String get dash => '---';

  @override
  String get rawFingerprintRecords => 'سجلات البصمات الخام';

  @override
  String get employeeData => 'بيانات الموظف';

  @override
  String get employeeCode => 'كود الموظف';

  @override
  String get attendanceStatus => 'حالة الدوام';

  @override
  String get shiftData => 'بيانات الوردية';

  @override
  String get attendanceTime => 'وقت الحضور';

  @override
  String get departureTime => 'وقت الانصراف';

  @override
  String errorLoadingRecords(String error) {
    return 'فشل تحميل السجلات: $error';
  }

  @override
  String get noRecordsForEmployee =>
      'لا توجد سجلات بصمات لهذا الموظف في هذا التاريخ';

  @override
  String get attendanceReport => 'تقرير الحضور';

  @override
  String get exportExcel => 'تصدير Excel';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get selectReportType => 'اختر نوع التقرير واضغط بحث';

  @override
  String currencyFormat(String amount) {
    return '$amount ر.ي';
  }

  @override
  String get addDevice => 'إضافة جهاز';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get ipAddress => 'عنوان IP';

  @override
  String get port => 'المنفذ';

  @override
  String get deviceType => 'نوع الجهاز';

  @override
  String get noDevices => 'لا توجد أجهزة';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get lastSync => 'آخر مزامنة';

  @override
  String get notSynced => 'لم تتم المزامنة';

  @override
  String get syncData => 'مزامنة البيانات';

  @override
  String get deviceId => 'المعرف (ID)';

  @override
  String get lastRequestDate => 'تاريخ آخر طلب';

  @override
  String get noRequestMade => 'لم يتم الطلب مسبقاً';

  @override
  String get firmwareVersion => 'اصدار Firmware';

  @override
  String get notAvailable => 'غير معرف';

  @override
  String get serialNumber => 'الرقم التسلسلي';

  @override
  String get fetchProperties => 'جلب الخصائص';

  @override
  String get deviceNameRequired => 'يرجى إدخال اسم الجهاز';

  @override
  String confirmDeleteDevice(String name) {
    return 'هل أنت متأكد من حذف الجهاز \"$name\"؟';
  }

  @override
  String get deviceManagement => 'إدارة أجهزة البصمة';

  @override
  String get deviceConnectedSuccess => 'تم الاتصال بالجهاز بنجاح';

  @override
  String get manageDevice => 'ادارة الجهاز';

  @override
  String get propertiesTab => 'الخصائص والسمات';

  @override
  String get employeesTab => 'الموظفين';

  @override
  String get fingerprintsTab => 'البصمات';

  @override
  String get attendanceTab => 'الحضور';

  @override
  String get liveCaptureTab => 'الاستماع المباشر';

  @override
  String employeeDetails(String name) {
    return 'تفاصيل الموظف: $name';
  }

  @override
  String get internalId => 'المعرف الداخلي';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get privilege => 'المجموعة';

  @override
  String get privilegeManager => 'مدير';

  @override
  String get privilegeSupervisor => 'مشرف عام';

  @override
  String get privilegeEnroller => 'مسجل';

  @override
  String get privilegeEmployee => 'موظف';

  @override
  String get knownEmployees => 'الموظفين المعرفين';

  @override
  String get addEmployee => 'إضافة موظف';

  @override
  String get sync => 'مزامنة';

  @override
  String get download => 'تحميل';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noTemplates => 'لا توجد بصمات مسجلة';

  @override
  String get valid => 'صالحة';

  @override
  String get invalid => 'غير صالحة';

  @override
  String get size => 'الحجم';

  @override
  String get flag => 'العلامة';

  @override
  String get stateLabel => 'الحالة';

  @override
  String get typeLabel => 'النوع';

  @override
  String get dateTimeLabel => 'التاريخ والوقت';

  @override
  String get employeeCodeLabel => 'رقم الموظف';

  @override
  String get stop => 'إيقاف';

  @override
  String get startListening => 'بدء الاستماع';

  @override
  String get waitingForFingerprints => 'بانتظار وصول بصمات...';

  @override
  String get deviceActivityReport => 'تقرير كثافة البصمات على الأجهزة';

  @override
  String get comingSoon => 'تقرير الكثافة قريباً';

  @override
  String get featureUnderDevelopment =>
      'هذه الميزة قيد التطوير وستكون متاحة قريباً';

  @override
  String get shiftManagement => 'إدارة الورديات';

  @override
  String get addShift => 'إضافة وردية';

  @override
  String get shiftName => 'اسم الوردية';

  @override
  String get shiftNameRequired => 'يرجى إدخال اسم الوردية';

  @override
  String get startTime => 'وقت البداية';

  @override
  String get endTime => 'وقت النهاية';

  @override
  String get nightShift => 'ليلية';

  @override
  String get overtimeShift => 'إضافي';

  @override
  String get holiday => 'عطلة';

  @override
  String get noShifts => 'لا توجد ورديات';

  @override
  String get editShift => 'تعديل وردية';

  @override
  String get addNewShift => 'إضافة وردية جديدة';

  @override
  String get editShiftData => 'تعديل بيانات الوردية';

  @override
  String get addShiftData => 'أدخل بيانات الوردية لإضافتها';

  @override
  String get earlyEntryBefore => 'بداية الدخول (قبل)';

  @override
  String get lateEntryAfter => 'نهاية الدخول (بعد)';

  @override
  String get earlyExitBefore => 'بداية الخروج (قبل)';

  @override
  String get lateExitAfter => 'نهاية الخروج (بعد)';

  @override
  String get maxAttendanceTime => 'أقصى وقت للحضور';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String confirmDeleteShift(String name) {
    return 'هل أنت متأكد من حذف الوردية \"$name\"?';
  }

  @override
  String get systemDashboard => 'لوحة تحكم النظام';

  @override
  String get systemSettingsDescription =>
      'إدارة الإعدادات العامة والثوابت الأساسية للنظام';

  @override
  String get shiftManagementCardDesc =>
      'إدارة أوقات الورديات، فترات السماح، وأيام العمل';

  @override
  String get deviceManagementCardDesc =>
      'إدارة أجهزة البصمة، الحالة، والمزامنة';

  @override
  String get newLabel => 'جديد';

  @override
  String get existingLabel => 'موجود';

  @override
  String selectedCountFormat(int selected, int total) {
    return 'المحدد: $selected من $total';
  }

  @override
  String get editBeforeSync => 'تعديل بيانات الموظف قبل المزامنة';

  @override
  String syncCompleteWithErrors(
    int created,
    int updated,
    int skipped,
    int failed,
  ) {
    return 'تمت المزامنة: $created إضافة، $updated تحديث، $skipped تجاهل، $failed فشل';
  }

  @override
  String syncCompleteSuccess(int created, int updated, int skipped) {
    return 'تمت المزامنة بنجاح: $created إضافة، $updated تحديث، $skipped تجاهل';
  }

  @override
  String get stateEntry => 'دخول';

  @override
  String get stateExit => 'خروج';

  @override
  String get stateBreakStart => 'بدء استراحة';

  @override
  String get stateBreakEnd => 'نهاية استراحة';

  @override
  String get stateOvertimeIn => 'عمل إضافي دخول';

  @override
  String get stateOvertimeOut => 'عمل إضافي خروج';

  @override
  String get typeFingerprint => 'بصمة';

  @override
  String get typePassword => 'كلمة سر';

  @override
  String get typeCard => 'بطاقة';

  @override
  String get typeFingerprintPassword => 'بصمة+كلمة سر';

  @override
  String get syncAttendanceRecords => 'مزامنة سجلات الحضور';

  @override
  String recordsInDevice(int count) {
    return 'عدد السجلات في الجهاز: $count';
  }

  @override
  String get inDatabase => 'موجود في DB';

  @override
  String get notFoundInDb => '--- (غير موجود)';

  @override
  String get noEmployee => 'بدون موظف';

  @override
  String syncResultSummary(int selectedCount, int noEmployeeCount) {
    return 'المحدد: $selectedCount جديد، $noEmployeeCount بدون موظف';
  }

  @override
  String get syncing => 'جارٍ المزامنة...';

  @override
  String get syncAttendanceBtn => 'مزامنة البيانات';

  @override
  String get recordsWithoutEmployeeWarning =>
      'السجلات بدون موظف (رقم الموظف غير موجود في قاعدة البيانات) لن تتم مزامنتها';

  @override
  String syncAttendanceResult(int created, int skipped, int failed) {
    return 'تمت المزامنة: $created إضافة، $skipped تجاهل، $failed فشل';
  }

  @override
  String syncAttendanceResultSuccess(int created, int skipped) {
    return 'تمت المزامنة بنجاح: $created سجل جديد، $skipped تجاهل';
  }

  @override
  String get proPlusAttendance => 'Pro-Plus Attendance';

  @override
  String get splashInitializing => 'جاري تهيئة التطبيق...';

  @override
  String get splashStartingPostgres => 'جاري تشغيل قاعدة البيانات...';

  @override
  String get splashStartingBackend => 'جاري تشغيل الخادم...';

  @override
  String get splashReady => 'التطبيق جاهز';

  @override
  String get splashError => 'حدث خطأ أثناء التهيئة';

  @override
  String get splashRetry => 'إعادة المحاولة';
}
