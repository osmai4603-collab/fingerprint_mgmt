import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// عنوان التطبيق
  ///
  /// In ar, this message translates to:
  /// **'نظام برو-بلس لإدارة الحضور'**
  String get appTitle;

  /// عنوان شاشة الدخول - نظام إدارة البصمات
  ///
  /// In ar, this message translates to:
  /// **'نظام إدارة البصمات'**
  String get fingerprintSystem;

  /// زر تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// رسالة خطأ عند فشل تسجيل الدخول
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الدخول'**
  String get loginFailed;

  /// نص ترحيبي في شاشة الدخول
  ///
  /// In ar, this message translates to:
  /// **'قم بتسجيل الدخول للمتابعة'**
  String get loginToContinue;

  /// زر تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// رسالة تأكيد تسجيل الخروج
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get confirmLogoutMessage;

  /// حقل اسم المستخدم
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// رسالة خطأ حقل اسم المستخدم مطلوب
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم المستخدم'**
  String get usernameRequired;

  /// حقل كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// رسالة خطأ حقل كلمة المرور مطلوب
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال كلمة المرور'**
  String get passwordRequired;

  /// رسالة خطأ طول كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get passwordMinLength;

  /// رسالة خطأ عدم تطابق كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة'**
  String get passwordMismatch;

  /// رسالة خطأ بيانات الدخول غير صحيحة
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدخول غير صحيحة أو الحساب غير نشط'**
  String get invalidCredentials;

  /// حقل كلمة المرور الحالية
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// حقل كلمة المرور الجديدة
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// حقل تأكيد كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// زر تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// عنوان نافذة تغيير كلمة المرور لمستخدم معين
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور للمستخدم: {username}'**
  String changePasswordFor(String username);

  /// عنوان صفحة الإعدادات
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// خيار اللغة
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// خيار المظهر
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// وصف خيار المظهر
  ///
  /// In ar, this message translates to:
  /// **'تخصيص ألوان واجهة التطبيق'**
  String get appearanceDesc;

  /// المظهر الفاتح
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get lightTheme;

  /// المظهر الداكن
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get darkTheme;

  /// المظهر حسب النظام
  ///
  /// In ar, this message translates to:
  /// **'نظام'**
  String get systemTheme;

  /// عنوان لوحة التحكم
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// رابط الصفحة الرئيسية
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// قائمة الموظفين
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get employees;

  /// الحضور والانصراف
  ///
  /// In ar, this message translates to:
  /// **'الحضور والانصراف'**
  String get attendance;

  /// عنوان شريط القائمة
  ///
  /// In ar, this message translates to:
  /// **'نظام إدارة الحضور'**
  String get attendanceManagementSystem;

  /// عنوان التقارير
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// النظام
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// عنوان صفحة إدارة المستخدمين
  ///
  /// In ar, this message translates to:
  /// **'إدارة المستخدمين'**
  String get usersManagement;

  /// زر إضافة مستخدم جديد
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get addUser;

  /// عنوان نافذة تعديل المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تعديل مستخدم'**
  String get editUser;

  /// زر حذف مستخدم
  ///
  /// In ar, this message translates to:
  /// **'حذف مستخدم'**
  String get deleteUser;

  /// خيار الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// وصف خيار الإشعارات
  ///
  /// In ar, this message translates to:
  /// **'إعدادات التنبيهات والإشعارات'**
  String get notificationsDesc;

  /// خيار حول التطبيق
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get about;

  /// وصف التطبيق
  ///
  /// In ar, this message translates to:
  /// **'نظام برو-بلس لإدارة الحضور v1.0.0'**
  String get aboutDesc;

  /// نص تفعيل المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تفعيل'**
  String get activate;

  /// نص تعطيل المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تعطيل'**
  String get deactivate;

  /// حقل الدور
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// دور المدير
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get roleAdmin;

  /// دور الموارد البشرية
  ///
  /// In ar, this message translates to:
  /// **'موارد بشرية'**
  String get roleHR;

  /// دور المشاهد
  ///
  /// In ar, this message translates to:
  /// **'مشاهد'**
  String get roleViewer;

  /// قائمة المستخدمين
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get users;

  /// رسالة عدم وجود مستخدمين
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون'**
  String get noUsers;

  /// عنوان نافذة تأكيد الحذف
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// رسالة تأكيد حذف المستخدم
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف المستخدم'**
  String get confirmDeleteMessage;

  /// رسالة تأكيد حذف مستخدم معين
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف المستخدم \"{username}\"؟'**
  String confirmDeleteUser(String username);

  /// رسالة نجاح تغيير كلمة المرور
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get passwordChanged;

  /// رسالة نجاح إنشاء مستخدم
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المستخدم بنجاح'**
  String get userCreated;

  /// رسالة نجاح تحديث المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المستخدم بنجاح'**
  String get userUpdated;

  /// رسالة نجاح حذف المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستخدم بنجاح'**
  String get userDeleted;

  /// رسالة نجاح تحديث الحالة
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الحالة بنجاح'**
  String get statusUpdated;

  /// زر إلغاء
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// زر حفظ
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// زر تأكيد
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// زر إضافة
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get addNew;

  /// زر تحديث
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// زر حذف
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// زر إغلاق
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// زر إعادة تحميل
  ///
  /// In ar, this message translates to:
  /// **'إعادة تحميل'**
  String get reload;

  /// حقل الحالة
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get status;

  /// رأس جدول الإجراءات
  ///
  /// In ar, this message translates to:
  /// **'الإجراءات'**
  String get actions;

  /// نص الحالة نشط
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get active;

  /// نص الحالة غير نشط
  ///
  /// In ar, this message translates to:
  /// **'غير نشط'**
  String get inactive;

  /// نص مفعل
  ///
  /// In ar, this message translates to:
  /// **'مفعل'**
  String get enabled;

  /// نص معطل
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get disabled;

  /// تلميح عدم القدرة على تعطيل المستخدم الحالي
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعطيل المستخدم الحالي'**
  String get cannotDisableCurrentUser;

  /// تلميح عدم القدرة على تعديل المستخدم الحالي
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعديل المستخدم الحالي'**
  String get cannotEditCurrentUser;

  /// تلميح عدم القدرة على حذف المستخدم الحالي
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف المستخدم الحالي'**
  String get cannotDeleteCurrentUser;

  /// نص توضيحي لتعديل المستخدم
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات المستخدم وصلاحياته'**
  String get editUserDataPermissions;

  /// نص توضيحي لإضافة مستخدم
  ///
  /// In ar, this message translates to:
  /// **'أدخل بيانات المستخدم لإضافته للنظام'**
  String get addUserDataPrompt;

  /// حقل الاسم الكامل
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get fullName;

  /// حقل رقم الموظف
  ///
  /// In ar, this message translates to:
  /// **'رقم الموظف'**
  String get employeeId;

  /// حقل رقم الموظف UserId
  ///
  /// In ar, this message translates to:
  /// **'رقم الموظف (UserId)'**
  String get employeeUserId;

  /// تلميح حقل رقم الموظف
  ///
  /// In ar, this message translates to:
  /// **'ادخل رقم الموظف ID'**
  String get employeeUserIdHint;

  /// زر توليد رقم فريد
  ///
  /// In ar, this message translates to:
  /// **'توليد رقم فريد'**
  String get generateUniqueId;

  /// رسالة خطأ الاسم مطلوب
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get nameRequired;

  /// حقل القسم
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get department;

  /// حقل المنصب
  ///
  /// In ar, this message translates to:
  /// **'المنصب'**
  String get position;

  /// حقل الهاتف
  ///
  /// In ar, this message translates to:
  /// **'الهاتف'**
  String get phone;

  /// حقل البريد الإلكتروني
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// حقل تاريخ التوظيف
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التوظيف'**
  String get hireDate;

  /// حقل العنوان
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get address;

  /// حقل البصمة
  ///
  /// In ar, this message translates to:
  /// **'البصمة'**
  String get fingerPrint;

  /// زر بحث
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// تلميح حقل البحث
  ///
  /// In ar, this message translates to:
  /// **'بحث بالاسم أو الرمز أو البطاقة...'**
  String get searchByNameOrCode;

  /// خيار الكل
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// حقل المجموعة
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get group;

  /// زر استيراد CSV
  ///
  /// In ar, this message translates to:
  /// **'استيراد CSV'**
  String get importCSV;

  /// زر إضافة موظف جديد
  ///
  /// In ar, this message translates to:
  /// **'إضافة موظف جديد'**
  String get addNewEmployee;

  /// حقل الرمز
  ///
  /// In ar, this message translates to:
  /// **'الرمز'**
  String get code;

  /// حقل الاسم
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get name;

  /// حقل البطاقة
  ///
  /// In ar, this message translates to:
  /// **'البطاقة'**
  String get card;

  /// حقل رقم البطاقة
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة (CardNo)'**
  String get cardNo;

  /// زر الملف الشخصي
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// زر إدارة البصمات
  ///
  /// In ar, this message translates to:
  /// **'إدارة البصمات'**
  String get manageFingerprints;

  /// عنوان إدارة بصمات موظف
  ///
  /// In ar, this message translates to:
  /// **'إدارة البصمات - {name}'**
  String manageFingerprintsFor(String name);

  /// نتيجة استيراد الموظفين
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة {created} وتحديث {updated}'**
  String employeeImportResult(int created, int updated);

  /// نتيجة استيراد الموظفين مع أخطاء
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة {created} وتحديث {updated} ({errors} أخطاء)'**
  String employeeImportResultWithErrors(int created, int updated, int errors);

  /// رسالة تأكيد حذف موظف
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {name}؟'**
  String confirmDeleteEmployee(String name);

  /// رسالة عدم وجود بيانات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noRecordsFound;

  /// رسالة عدم وجود موظفين
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موظفون'**
  String get noEmployees;

  /// خيار بدون وردية
  ///
  /// In ar, this message translates to:
  /// **'بدون وردية'**
  String get withoutShift;

  /// عنوان ملخص الإحصائيات
  ///
  /// In ar, this message translates to:
  /// **'ملخص الإحصائيات'**
  String get statsSummary;

  /// عنوان ساعات العمل
  ///
  /// In ar, this message translates to:
  /// **'ساعات العمل'**
  String get workHours;

  /// عنوان التأخير
  ///
  /// In ar, this message translates to:
  /// **'التأخير'**
  String get lateTime;

  /// عنوان العمل الإضافي
  ///
  /// In ar, this message translates to:
  /// **'العمل الإضافي'**
  String get overtime;

  /// عنوان البصمات
  ///
  /// In ar, this message translates to:
  /// **'البصمات'**
  String get fingerprints;

  /// حقل رقم الإصبع
  ///
  /// In ar, this message translates to:
  /// **'رقم الإصبع'**
  String get fingerprintNumber;

  /// تلميح حقل النص البيومتري
  ///
  /// In ar, this message translates to:
  /// **'أدخل نص البصمة البيومترية...'**
  String get biometricTextHint;

  /// تلميح بحث بالبصمة
  ///
  /// In ar, this message translates to:
  /// **'بحث بالبصمة...'**
  String get searchByFingerprint;

  /// رسالة تأكيد حذف بصمة
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه البصمة؟'**
  String get confirmDeleteFingerprint;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// نص نظرة عامة
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على نظام الحضور والانصراف'**
  String get overview;

  /// عدد الموظفين النشطين
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط'**
  String activeEmployees(int count);

  /// عنوان الورديات
  ///
  /// In ar, this message translates to:
  /// **'الورديات'**
  String get shifts;

  /// عنوان الأجهزة
  ///
  /// In ar, this message translates to:
  /// **'الأجهزة'**
  String get devices;

  /// عنوان الأكثر غيابا
  ///
  /// In ar, this message translates to:
  /// **'الأكثر غيابا'**
  String get mostAbsent;

  /// اختصار الساعات
  ///
  /// In ar, this message translates to:
  /// **'{hours} س'**
  String hoursAbbreviation(double hours);

  /// عنوان الأكثر حضورا
  ///
  /// In ar, this message translates to:
  /// **'الأكثر حضورا'**
  String get mostPresent;

  /// عنوان الأكثر تأخيرا
  ///
  /// In ar, this message translates to:
  /// **'الأكثر تأخيرا'**
  String get mostLate;

  /// عدد المرات
  ///
  /// In ar, this message translates to:
  /// **'{count} مرة'**
  String timesCount(int count);

  /// رسالة لا توجد بيانات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// عنوان آخر النشاطات
  ///
  /// In ar, this message translates to:
  /// **'آخر النشاطات'**
  String get recentActivities;

  /// رسالة لا توجد نشاطات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نشاطات اليوم'**
  String get noActivitiesToday;

  /// نص بصمة غير معروفة
  ///
  /// In ar, this message translates to:
  /// **'بصمة غير معروفة'**
  String get unknownFingerprint;

  /// نص غير مرتبط
  ///
  /// In ar, this message translates to:
  /// **'غير مرتبط'**
  String get unlinked;

  /// عنوان ملخص اليوم
  ///
  /// In ar, this message translates to:
  /// **'ملخص اليوم'**
  String get todaySummary;

  /// حالة حاضر
  ///
  /// In ar, this message translates to:
  /// **'حاضر'**
  String get present;

  /// حالة غائب
  ///
  /// In ar, this message translates to:
  /// **'غائب'**
  String get absent;

  /// حالة متأخر
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get lateStatus;

  /// تبويب البصمات الخام
  ///
  /// In ar, this message translates to:
  /// **'البصمات الخام'**
  String get rawFingerprints;

  /// تلميح إلغاء فلتر التاريخ
  ///
  /// In ar, this message translates to:
  /// **'إلغاء فلتر التاريخ'**
  String get clearDateFilter;

  /// خيار كل الموظفين
  ///
  /// In ar, this message translates to:
  /// **'كل الموظفين'**
  String get allEmployees;

  /// خيار غير المعروفة فقط
  ///
  /// In ar, this message translates to:
  /// **'غير المعروفة فقط'**
  String get unknownOnly;

  /// زر إضافة حضور يدوي
  ///
  /// In ar, this message translates to:
  /// **'إضافة حضور يدوي'**
  String get addManualAttendance;

  /// رسالة لا توجد بصمات خام
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بصمات خام'**
  String get noRawFingerprints;

  /// حقل الموظف
  ///
  /// In ar, this message translates to:
  /// **'الموظف'**
  String get employee;

  /// حقل وقت البصمة
  ///
  /// In ar, this message translates to:
  /// **'وقت البصمة'**
  String get dateTime;

  /// حقل الجهاز
  ///
  /// In ar, this message translates to:
  /// **'الجهاز'**
  String get device;

  /// حقل الإجراء
  ///
  /// In ar, this message translates to:
  /// **'إجراء'**
  String get action;

  /// نص موظف غير معروف مع الرقم
  ///
  /// In ar, this message translates to:
  /// **'غير معروف (ID: {id})'**
  String unknownWithId(int id);

  /// زر ربط بموظف
  ///
  /// In ar, this message translates to:
  /// **'ربط بموظف'**
  String get linkToEmployee;

  /// عنوان إضافة بصمة يدوية
  ///
  /// In ar, this message translates to:
  /// **'إضافة بصمة يدوية'**
  String get addManualFingerprint;

  /// تلميح اختيار بيانات الموظف
  ///
  /// In ar, this message translates to:
  /// **'حدد بيانات الموظف'**
  String get selectEmployeeData;

  /// تنسيق اسم الموظف مع الرقم
  ///
  /// In ar, this message translates to:
  /// **'{name} (ID: {id})'**
  String employeeNameIdFormat(String name, String id);

  /// رسالة خطأ جلب الموظفين
  ///
  /// In ar, this message translates to:
  /// **'خطأ في جلب الموظفين'**
  String get errorFetchingEmployees;

  /// حقل وقت البصمة
  ///
  /// In ar, this message translates to:
  /// **'وقت البصمة'**
  String get fingerprintTime;

  /// عنوان ربط بصمة بموظف
  ///
  /// In ar, this message translates to:
  /// **'ربط بصمة بموظف'**
  String get linkFingerprintToEmployee;

  /// تلميح اختيار الموظف
  ///
  /// In ar, this message translates to:
  /// **'اختر الموظف'**
  String get selectEmployee;

  /// زر ربط
  ///
  /// In ar, this message translates to:
  /// **'ربط'**
  String get link;

  /// حقل من تاريخ
  ///
  /// In ar, this message translates to:
  /// **'من تاريخ'**
  String get fromDate;

  /// حقل إلى تاريخ
  ///
  /// In ar, this message translates to:
  /// **'إلى تاريخ'**
  String get toDate;

  /// زر تحديث
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// زر Excel
  ///
  /// In ar, this message translates to:
  /// **'Excel'**
  String get excel;

  /// زر PDF
  ///
  /// In ar, this message translates to:
  /// **'PDF'**
  String get pdf;

  /// رسالة نجاح تصدير التقرير
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير التقرير بنجاح'**
  String get reportExported;

  /// رأس جدول الرقم
  ///
  /// In ar, this message translates to:
  /// **'No.'**
  String get tableNo;

  /// رأس جدول اسم الموظف
  ///
  /// In ar, this message translates to:
  /// **'اسم الموظف'**
  String get employeeName;

  /// رأس جدول الوردية
  ///
  /// In ar, this message translates to:
  /// **'الوردية'**
  String get shiftLabel;

  /// حقل التاريخ
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get dateLabel;

  /// رأس جدول أول بصمة
  ///
  /// In ar, this message translates to:
  /// **'أول بصمة'**
  String get firstFingerprint;

  /// رأس جدول آخر بصمة
  ///
  /// In ar, this message translates to:
  /// **'آخر بصمة'**
  String get lastFingerprint;

  /// رأس جدول عدد الساعات
  ///
  /// In ar, this message translates to:
  /// **'عدد الساعات'**
  String get totalHours;

  /// رأس جدول عدد البصمات
  ///
  /// In ar, this message translates to:
  /// **'عدد البصمات'**
  String get fingerprintCount;

  /// إجمالي أيام الدوام
  ///
  /// In ar, this message translates to:
  /// **'إجمالي أيام الدوام: {count}'**
  String totalAttendanceDays(int count);

  /// إجمالي الساعات
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الساعات: {hours}'**
  String totalHoursSummary(String hours);

  /// نص شرطة للقيم الفارغة
  ///
  /// In ar, this message translates to:
  /// **'---'**
  String get dash;

  /// عنوان سجلات البصمات الخام
  ///
  /// In ar, this message translates to:
  /// **'سجلات البصمات الخام'**
  String get rawFingerprintRecords;

  /// عنوان بيانات الموظف
  ///
  /// In ar, this message translates to:
  /// **'بيانات الموظف'**
  String get employeeData;

  /// حقل كود الموظف
  ///
  /// In ar, this message translates to:
  /// **'كود الموظف'**
  String get employeeCode;

  /// حقل حالة الدوام
  ///
  /// In ar, this message translates to:
  /// **'حالة الدوام'**
  String get attendanceStatus;

  /// عنوان بيانات الوردية
  ///
  /// In ar, this message translates to:
  /// **'بيانات الوردية'**
  String get shiftData;

  /// حقل وقت الحضور
  ///
  /// In ar, this message translates to:
  /// **'وقت الحضور'**
  String get attendanceTime;

  /// حقل وقت الانصراف
  ///
  /// In ar, this message translates to:
  /// **'وقت الانصراف'**
  String get departureTime;

  /// رسالة خطأ تحميل السجلات
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل السجلات: {error}'**
  String errorLoadingRecords(String error);

  /// رسالة لا توجد سجلات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات بصمات لهذا الموظف في هذا التاريخ'**
  String get noRecordsForEmployee;

  /// عنوان تقرير الحضور
  ///
  /// In ar, this message translates to:
  /// **'تقرير الحضور'**
  String get attendanceReport;

  /// زر تصدير Excel
  ///
  /// In ar, this message translates to:
  /// **'تصدير Excel'**
  String get exportExcel;

  /// زر تصدير PDF
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get exportPdf;

  /// رسالة اختر نوع التقرير
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع التقرير واضغط بحث'**
  String get selectReportType;

  /// تنسيق العملة
  ///
  /// In ar, this message translates to:
  /// **'{amount} ر.ي'**
  String currencyFormat(String amount);

  /// زر إضافة جهاز
  ///
  /// In ar, this message translates to:
  /// **'إضافة جهاز'**
  String get addDevice;

  /// حقل اسم الجهاز
  ///
  /// In ar, this message translates to:
  /// **'اسم الجهاز'**
  String get deviceName;

  /// حقل عنوان IP
  ///
  /// In ar, this message translates to:
  /// **'عنوان IP'**
  String get ipAddress;

  /// حقل المنفذ
  ///
  /// In ar, this message translates to:
  /// **'المنفذ'**
  String get port;

  /// حقل نوع الجهاز
  ///
  /// In ar, this message translates to:
  /// **'نوع الجهاز'**
  String get deviceType;

  /// رسالة لا توجد أجهزة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أجهزة'**
  String get noDevices;

  /// حالة متصل
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get connected;

  /// حالة غير متصل
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get disconnected;

  /// حقل آخر مزامنة
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة'**
  String get lastSync;

  /// نص لم تتم المزامنة
  ///
  /// In ar, this message translates to:
  /// **'لم تتم المزامنة'**
  String get notSynced;

  /// زر مزامنة البيانات
  ///
  /// In ar, this message translates to:
  /// **'مزامنة البيانات'**
  String get syncData;

  /// حقل معرف الجهاز
  ///
  /// In ar, this message translates to:
  /// **'المعرف (ID)'**
  String get deviceId;

  /// حقل تاريخ آخر طلب
  ///
  /// In ar, this message translates to:
  /// **'تاريخ آخر طلب'**
  String get lastRequestDate;

  /// نص لم يتم الطلب
  ///
  /// In ar, this message translates to:
  /// **'لم يتم الطلب مسبقاً'**
  String get noRequestMade;

  /// حقل اصدار Firmware
  ///
  /// In ar, this message translates to:
  /// **'اصدار Firmware'**
  String get firmwareVersion;

  /// نص غير معرف
  ///
  /// In ar, this message translates to:
  /// **'غير معرف'**
  String get notAvailable;

  /// حقل الرقم التسلسلي
  ///
  /// In ar, this message translates to:
  /// **'الرقم التسلسلي'**
  String get serialNumber;

  /// زر جلب الخصائص
  ///
  /// In ar, this message translates to:
  /// **'جلب الخصائص'**
  String get fetchProperties;

  /// رسالة خطأ اسم الجهاز مطلوب
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم الجهاز'**
  String get deviceNameRequired;

  /// رسالة تأكيد حذف جهاز
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف الجهاز \"{name}\"؟'**
  String confirmDeleteDevice(String name);

  /// عنوان إدارة أجهزة البصمة
  ///
  /// In ar, this message translates to:
  /// **'إدارة أجهزة البصمة'**
  String get deviceManagement;

  /// رسالة نجاح الاتصال بالجهاز
  ///
  /// In ar, this message translates to:
  /// **'تم الاتصال بالجهاز بنجاح'**
  String get deviceConnectedSuccess;

  /// نص إدارة الجهاز
  ///
  /// In ar, this message translates to:
  /// **'ادارة الجهاز'**
  String get manageDevice;

  /// تبويب الخصائص والسمات
  ///
  /// In ar, this message translates to:
  /// **'الخصائص والسمات'**
  String get propertiesTab;

  /// تبويب الموظفين
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get employeesTab;

  /// تبويب البصمات
  ///
  /// In ar, this message translates to:
  /// **'البصمات'**
  String get fingerprintsTab;

  /// تبويب الحضور
  ///
  /// In ar, this message translates to:
  /// **'الحضور'**
  String get attendanceTab;

  /// تبويب الاستماع المباشر
  ///
  /// In ar, this message translates to:
  /// **'الاستماع المباشر'**
  String get liveCaptureTab;

  /// عنوان تفاصيل الموظف
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الموظف: {name}'**
  String employeeDetails(String name);

  /// حقل المعرف الداخلي
  ///
  /// In ar, this message translates to:
  /// **'المعرف الداخلي'**
  String get internalId;

  /// حقل رقم البطاقة
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get cardNumber;

  /// حقل المجموعة
  ///
  /// In ar, this message translates to:
  /// **'المجموعة'**
  String get privilege;

  /// صلاحية مدير
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get privilegeManager;

  /// صلاحية مشرف عام
  ///
  /// In ar, this message translates to:
  /// **'مشرف عام'**
  String get privilegeSupervisor;

  /// صلاحية مسجل
  ///
  /// In ar, this message translates to:
  /// **'مسجل'**
  String get privilegeEnroller;

  /// صلاحية موظف
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get privilegeEmployee;

  /// عنوان الموظفين المعرفين
  ///
  /// In ar, this message translates to:
  /// **'الموظفين المعرفين'**
  String get knownEmployees;

  /// زر إضافة موظف
  ///
  /// In ar, this message translates to:
  /// **'إضافة موظف'**
  String get addEmployee;

  /// زر مزامنة
  ///
  /// In ar, this message translates to:
  /// **'مزامنة'**
  String get sync;

  /// زر تحميل
  ///
  /// In ar, this message translates to:
  /// **'تحميل'**
  String get download;

  /// نص جارٍ التحميل
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// رسالة لا توجد بصمات مسجلة
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بصمات مسجلة'**
  String get noTemplates;

  /// نص صالحة
  ///
  /// In ar, this message translates to:
  /// **'صالحة'**
  String get valid;

  /// نص غير صالحة
  ///
  /// In ar, this message translates to:
  /// **'غير صالحة'**
  String get invalid;

  /// حقل الحجم
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get size;

  /// حقل العلامة
  ///
  /// In ar, this message translates to:
  /// **'العلامة'**
  String get flag;

  /// رأس جدول الحالة
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get stateLabel;

  /// رأس جدول النوع
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get typeLabel;

  /// رأس جدول التاريخ والوقت
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والوقت'**
  String get dateTimeLabel;

  /// رأس جدول رقم الموظف
  ///
  /// In ar, this message translates to:
  /// **'رقم الموظف'**
  String get employeeCodeLabel;

  /// زر إيقاف
  ///
  /// In ar, this message translates to:
  /// **'إيقاف'**
  String get stop;

  /// زر بدء الاستماع
  ///
  /// In ar, this message translates to:
  /// **'بدء الاستماع'**
  String get startListening;

  /// نص انتظار البصمات
  ///
  /// In ar, this message translates to:
  /// **'بانتظار وصول بصمات...'**
  String get waitingForFingerprints;

  /// عنوان تقرير كثافة البصمات
  ///
  /// In ar, this message translates to:
  /// **'تقرير كثافة البصمات على الأجهزة'**
  String get deviceActivityReport;

  /// نص قريباً
  ///
  /// In ar, this message translates to:
  /// **'تقرير الكثافة قريباً'**
  String get comingSoon;

  /// وصف ميزة قيد التطوير
  ///
  /// In ar, this message translates to:
  /// **'هذه الميزة قيد التطوير وستكون متاحة قريباً'**
  String get featureUnderDevelopment;

  /// عنوان إدارة الورديات
  ///
  /// In ar, this message translates to:
  /// **'إدارة الورديات'**
  String get shiftManagement;

  /// زر إضافة وردية
  ///
  /// In ar, this message translates to:
  /// **'إضافة وردية'**
  String get addShift;

  /// حقل اسم الوردية
  ///
  /// In ar, this message translates to:
  /// **'اسم الوردية'**
  String get shiftName;

  /// رسالة خطأ اسم الوردية مطلوب
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم الوردية'**
  String get shiftNameRequired;

  /// حقل وقت البداية
  ///
  /// In ar, this message translates to:
  /// **'وقت البداية'**
  String get startTime;

  /// حقل وقت النهاية
  ///
  /// In ar, this message translates to:
  /// **'وقت النهاية'**
  String get endTime;

  /// خيار وردية ليلية
  ///
  /// In ar, this message translates to:
  /// **'ليلية'**
  String get nightShift;

  /// خيار إضافي
  ///
  /// In ar, this message translates to:
  /// **'إضافي'**
  String get overtimeShift;

  /// خيار عطلة
  ///
  /// In ar, this message translates to:
  /// **'عطلة'**
  String get holiday;

  /// رسالة لا توجد ورديات
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ورديات'**
  String get noShifts;

  /// عنوان تعديل وردية
  ///
  /// In ar, this message translates to:
  /// **'تعديل وردية'**
  String get editShift;

  /// عنوان إضافة وردية جديدة
  ///
  /// In ar, this message translates to:
  /// **'إضافة وردية جديدة'**
  String get addNewShift;

  /// وصف تعديل الوردية
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الوردية'**
  String get editShiftData;

  /// وصف إضافة الوردية
  ///
  /// In ar, this message translates to:
  /// **'أدخل بيانات الوردية لإضافتها'**
  String get addShiftData;

  /// حقل بداية الدخول قبل
  ///
  /// In ar, this message translates to:
  /// **'بداية الدخول (قبل)'**
  String get earlyEntryBefore;

  /// حقل نهاية الدخول بعد
  ///
  /// In ar, this message translates to:
  /// **'نهاية الدخول (بعد)'**
  String get lateEntryAfter;

  /// حقل بداية الخروج قبل
  ///
  /// In ar, this message translates to:
  /// **'بداية الخروج (قبل)'**
  String get earlyExitBefore;

  /// حقل نهاية الخروج بعد
  ///
  /// In ar, this message translates to:
  /// **'نهاية الخروج (بعد)'**
  String get lateExitAfter;

  /// حقل أقصى وقت للحضور
  ///
  /// In ar, this message translates to:
  /// **'أقصى وقت للحضور'**
  String get maxAttendanceTime;

  /// نص جاري الحفظ
  ///
  /// In ar, this message translates to:
  /// **'جاري الحفظ...'**
  String get saving;

  /// رسالة تأكيد حذف وردية
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف الوردية \"{name}\"?'**
  String confirmDeleteShift(String name);

  /// عنوان لوحة تحكم النظام
  ///
  /// In ar, this message translates to:
  /// **'لوحة تحكم النظام'**
  String get systemDashboard;

  /// وصف إعدادات النظام
  ///
  /// In ar, this message translates to:
  /// **'إدارة الإعدادات العامة والثوابت الأساسية للنظام'**
  String get systemSettingsDescription;

  /// وصف بطاقة إدارة الورديات
  ///
  /// In ar, this message translates to:
  /// **'إدارة أوقات الورديات، فترات السماح، وأيام العمل'**
  String get shiftManagementCardDesc;

  /// وصف بطاقة إدارة الأجهزة
  ///
  /// In ar, this message translates to:
  /// **'إدارة أجهزة البصمة، الحالة، والمزامنة'**
  String get deviceManagementCardDesc;

  /// نص جديد
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newLabel;

  /// نص موجود
  ///
  /// In ar, this message translates to:
  /// **'موجود'**
  String get existingLabel;

  /// تنسيق عدد المحدد
  ///
  /// In ar, this message translates to:
  /// **'المحدد: {selected} من {total}'**
  String selectedCountFormat(int selected, int total);

  /// عنوان تعديل قبل المزامنة
  ///
  /// In ar, this message translates to:
  /// **'تعديل بيانات الموظف قبل المزامنة'**
  String get editBeforeSync;

  /// نتيجة المزامنة مع أخطاء
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة: {created} إضافة، {updated} تحديث، {skipped} تجاهل، {failed} فشل'**
  String syncCompleteWithErrors(
    int created,
    int updated,
    int skipped,
    int failed,
  );

  /// نتيجة المزامنة بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح: {created} إضافة، {updated} تحديث، {skipped} تجاهل'**
  String syncCompleteSuccess(int created, int updated, int skipped);

  /// حالة دخول
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get stateEntry;

  /// حالة خروج
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get stateExit;

  /// حالة بدء استراحة
  ///
  /// In ar, this message translates to:
  /// **'بدء استراحة'**
  String get stateBreakStart;

  /// حالة نهاية استراحة
  ///
  /// In ar, this message translates to:
  /// **'نهاية استراحة'**
  String get stateBreakEnd;

  /// حالة عمل إضافي دخول
  ///
  /// In ar, this message translates to:
  /// **'عمل إضافي دخول'**
  String get stateOvertimeIn;

  /// حالة عمل إضافي خروج
  ///
  /// In ar, this message translates to:
  /// **'عمل إضافي خروج'**
  String get stateOvertimeOut;

  /// نوع بصمة
  ///
  /// In ar, this message translates to:
  /// **'بصمة'**
  String get typeFingerprint;

  /// نوع كلمة سر
  ///
  /// In ar, this message translates to:
  /// **'كلمة سر'**
  String get typePassword;

  /// نوع بطاقة
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get typeCard;

  /// نوع بصمة وكلمة سر
  ///
  /// In ar, this message translates to:
  /// **'بصمة+كلمة سر'**
  String get typeFingerprintPassword;

  /// عنوان مزامنة الحضور
  ///
  /// In ar, this message translates to:
  /// **'مزامنة سجلات الحضور'**
  String get syncAttendanceRecords;

  /// عدد السجلات في الجهاز
  ///
  /// In ar, this message translates to:
  /// **'عدد السجلات في الجهاز: {count}'**
  String recordsInDevice(int count);

  /// نص موجود في قاعدة البيانات
  ///
  /// In ar, this message translates to:
  /// **'موجود في DB'**
  String get inDatabase;

  /// نص غير موجود في قاعدة البيانات
  ///
  /// In ar, this message translates to:
  /// **'--- (غير موجود)'**
  String get notFoundInDb;

  /// نص بدون موظف
  ///
  /// In ar, this message translates to:
  /// **'بدون موظف'**
  String get noEmployee;

  /// ملخص نتائج المزامنة
  ///
  /// In ar, this message translates to:
  /// **'المحدد: {selectedCount} جديد، {noEmployeeCount} بدون موظف'**
  String syncResultSummary(int selectedCount, int noEmployeeCount);

  /// نص جارٍ المزامنة
  ///
  /// In ar, this message translates to:
  /// **'جارٍ المزامنة...'**
  String get syncing;

  /// زر مزامنة البيانات
  ///
  /// In ar, this message translates to:
  /// **'مزامنة البيانات'**
  String get syncAttendanceBtn;

  /// تحذير السجلات بدون موظف
  ///
  /// In ar, this message translates to:
  /// **'السجلات بدون موظف (رقم الموظف غير موجود في قاعدة البيانات) لن تتم مزامنتها'**
  String get recordsWithoutEmployeeWarning;

  /// نتيجة مزامنة الحضور مع أخطاء
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة: {created} إضافة، {skipped} تجاهل، {failed} فشل'**
  String syncAttendanceResult(int created, int skipped, int failed);

  /// نتيجة مزامنة الحضور بنجاح
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة بنجاح: {created} سجل جديد، {skipped} تجاهل'**
  String syncAttendanceResultSuccess(int created, int skipped);

  /// اسم التطبيق بالانجليزية
  ///
  /// In ar, this message translates to:
  /// **'Pro-Plus Attendance'**
  String get proPlusAttendance;

  /// حالة تهيئة التطبيق
  ///
  /// In ar, this message translates to:
  /// **'جاري تهيئة التطبيق...'**
  String get splashInitializing;

  /// حالة تشغيل قاعدة البيانات
  ///
  /// In ar, this message translates to:
  /// **'جاري تشغيل قاعدة البيانات...'**
  String get splashStartingPostgres;

  /// حالة تشغيل الخادم
  ///
  /// In ar, this message translates to:
  /// **'جاري تشغيل الخادم...'**
  String get splashStartingBackend;

  /// التطبيق جاهز للاستخدام
  ///
  /// In ar, this message translates to:
  /// **'التطبيق جاهز'**
  String get splashReady;

  /// رسالة خطأ في شاشة البداية
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التهيئة'**
  String get splashError;

  /// زر إعادة المحاولة
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get splashRetry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
