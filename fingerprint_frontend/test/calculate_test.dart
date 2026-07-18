// ignore_for_file: avoid_print

import 'package:fingerprint_frontend/calculate.dart';

// ─────────────────────────────────────────────────────────
// 1) واجهة مجردة (Interface) تعرّف عقد الدالة
// ─────────────────────────────────────────────────────────
abstract class ICalculateTime {
  DateTime? findMatchingTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime shiftStartTime,
    required DateTime maxAttendanceTime,
  });

  DateTime? findDepartureTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime beforeShiftEndTime,
    required DateTime afterShiftEndTime,
  });
}

// ─────────────────────────────────────────────────────────
// 2) Adaptee: يغلّف الكلاس الأصلي (Static) بدون تعديله
// ─────────────────────────────────────────────────────────
class CalculateTimeAdapter implements ICalculateTime {
  CalculateTimeAdapter();
  @override
  DateTime? findMatchingTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime shiftStartTime,
    required DateTime maxAttendanceTime,
  }) {
    return CalculateTime.findMatchingTimestamp(
      timestamps: timestamps,
      date: date,
      shiftStartTime: shiftStartTime,
      maxAttendanceTime: maxAttendanceTime,
    );
  }

  @override
  DateTime? findDepartureTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime beforeShiftEndTime,
    required DateTime afterShiftEndTime,
  }) {
    return CalculateTime.findDepartureTimestamp(
      timestamps: timestamps,
      date: date,
      beforeShiftEndTime: beforeShiftEndTime,
      afterShiftEndTime: afterShiftEndTime,
    );
  }
}

// ─────────────────────────────────────────────────────────
// 3) Decorator: يغلّف أي ICalculateTime ويضيف سلوك تسجيل
// ─────────────────────────────────────────────────────────
class LoggingCalculateTimeDecorator implements ICalculateTime {
  final ICalculateTime _inner;

  LoggingCalculateTimeDecorator(this._inner);

  @override
  DateTime? findMatchingTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime shiftStartTime,
    required DateTime maxAttendanceTime,
  }) {
    print('═' * 50);
    print('📥 المدخلات (حضور):');
    print('   التاريخ: $date');
    print('   بداية الوردية: $shiftStartTime');
    print('   الحد الأقصى: $maxAttendanceTime');
    print('   البصمات: $timestamps');
    print('─' * 50);

    final result = _inner.findMatchingTimestamp(
      timestamps: timestamps,
      date: date,
      shiftStartTime: shiftStartTime,
      maxAttendanceTime: maxAttendanceTime,
    );

    if (result != null) {
      print('✅ النتيجة: $result');
    } else {
      print('❌ النتيجة: لا توجد قيمة مطابقة');
    }
    print('═' * 50);
    print('');

    return result;
  }

  @override
  DateTime? findDepartureTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime beforeShiftEndTime,
    required DateTime afterShiftEndTime,
  }) {
    print('═' * 50);
    print('📥 المدخلات (خروج):');
    print('   التاريخ: $date');
    print('   قبل نهاية الفترة: $beforeShiftEndTime');
    print('   بعد نهاية الفترة: $afterShiftEndTime');
    print('   البصمات: $timestamps');
    print('─' * 50);

    final result = _inner.findDepartureTimestamp(
      timestamps: timestamps,
      date: date,
      beforeShiftEndTime: beforeShiftEndTime,
      afterShiftEndTime: afterShiftEndTime,
    );

    if (result != null) {
      print('✅ النتيجة: $result');
    } else {
      print('❌ النتيجة: لا توجد قيمة مطابقة');
    }
    print('═' * 50);
    print('');

    return result;
  }
}

// ─────────────────────────────────────────────────────────
// 4) تشغيل الاختبارات
// ─────────────────────────────────────────────────────────
void main() {
  // إنشاء الـ Decorator: Adapter ← LoggingDecorator
  final calculator = LoggingCalculateTimeDecorator(CalculateTimeAdapter());

  final date = DateTime(2026, 7, 16); // التاريخ

  // ── اختبار 1: بصمة ضمن النطاق ──
  print('🧪 اختبار 1: بصمة ضمن النطاق');
  final result1 = calculator.findMatchingTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 6, 30), // قبل البداية
      DateTime(2026, 7, 16, 7, 15), // ✅ ضمن النطاق
      DateTime(2026, 7, 16, 9, 0), // بعد الحد الأقصى
    ],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0), // 07:00
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30), // 08:30
  );
  assert(result1 != null, 'يجب أن يرجع قيمة');
  assert(result1!.hour == 7 && result1.minute == 15, 'يجب أن تكون 07:15');

  // ── اختبار 2: بصمة تساوي بداية الوردية بالضبط ──
  print('🧪 اختبار 2: بصمة تساوي بداية الوردية');
  final result2 = calculator.findMatchingTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 7, 0), // ✅ تساوي بداية الوردية
      DateTime(2026, 7, 16, 8, 0),
    ],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
  );
  assert(result2 != null, 'يجب أن يرجع قيمة');
  assert(result2!.hour == 7 && result2.minute == 0, 'يجب أن تكون 07:00');

  // ── اختبار 3: لا توجد بصمة ضمن النطاق ──
  print('🧪 اختبار 3: لا توجد بصمة ضمن النطاق');
  final result3 = calculator.findMatchingTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 5, 0), // قبل البداية
      DateTime(2026, 7, 16, 6, 30), // قبل البداية
      DateTime(2026, 7, 16, 9, 0), // بعد الحد الأقصى
    ],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
  );
  assert(result3 == null, 'يجب أن يرجع null');

  // ── اختبار 4: مصفوفة فارغة ──
  print('🧪 اختبار 4: مصفوفة فارغة');
  final result4 = calculator.findMatchingTimestamp(
    timestamps: [],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
  );
  assert(result4 == null, 'يجب أن يرجع null');

  // ── اختبار 5: بصمات غير مرتبة (التحقق من الترتيب التصاعدي) ──
  print('🧪 اختبار 5: بصمات غير مرتبة');
  final result5 = calculator.findMatchingTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 8, 0), // ضمن النطاق لكن ليست الأولى
      DateTime(2026, 7, 16, 9, 0), // خارج النطاق
      DateTime(2026, 7, 16, 7, 10), // ✅ الأولى بعد الترتيب
    ],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
  );
  assert(result5 != null, 'يجب أن يرجع قيمة');
  assert(result5!.hour == 7 && result5.minute == 10, 'يجب أن تكون 07:10');

  // ── اختبار 6: بصمة تساوي الحد الأقصى (يجب أن لا تُقبل) ──
  print('🧪 اختبار 6: بصمة تساوي الحد الأقصى');
  final result6 = calculator.findMatchingTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 8, 30), // تساوي الحد الأقصى - لا تُقبل
    ],
    date: date,
    shiftStartTime: DateTime(0, 0, 0, 7, 0),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
  );
  assert(result6 == null, 'يجب أن يرجع null - الحد الأقصى غير مشمول');

  print('🎉 جميع اختبارات الحضور نجحت!');
  print('');
  print('=' * 50);
  print('    اختبارات دالة الخروج (findDepartureTimestamp)');
  print('=' * 50);
  print('');

  // ── اختبار خروج 1: بصمة ضمن النطاق ──
  print('🧪 اختبار خروج 1: بصمة ضمن النطاق');
  final dep1 = calculator.findDepartureTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 14, 30), // قبل نهاية الفترة
      DateTime(2026, 7, 16, 15, 45), // ✅ ضمن النطاق
      DateTime(2026, 7, 16, 17, 0), // بعد نهاية الفترة
    ],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0), // 15:00
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30), // 16:30
  );
  assert(dep1 != null, 'يجب أن يرجع قيمة');
  assert(dep1!.hour == 15 && dep1.minute == 45, 'يجب أن تكون 15:45');

  // ── اختبار خروج 2: بصمة تساوي بعد نهاية الفترة (يجب أن تُقبل) ──
  print('🧪 اختبار خروج 2: بصمة تساوي بعد نهاية الفترة');
  final dep2 = calculator.findDepartureTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 16, 30), // ✅ تساوي بعد نهاية الفترة - تُقبل
    ],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0),
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30),
  );
  assert(dep2 != null, 'يجب أن يرجع قيمة');
  assert(dep2!.hour == 16 && dep2.minute == 30, 'يجب أن تكون 16:30');

  // ── اختبار خروج 3: بصمة تساوي قبل نهاية الفترة (يجب أن لا تُقبل) ──
  print('🧪 اختبار خروج 3: بصمة تساوي قبل نهاية الفترة');
  final dep3 = calculator.findDepartureTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 15, 0), // تساوي قبل نهاية الفترة - لا تُقبل
    ],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0),
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30),
  );
  assert(dep3 == null, 'يجب أن يرجع null - قبل نهاية الفترة غير مشمول');

  // ── اختبار خروج 4: لا توجد بصمة ضمن النطاق ──
  print('🧪 اختبار خروج 4: لا توجد بصمة ضمن النطاق');
  final dep4 = calculator.findDepartureTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 13, 0), // قبل النطاق
      DateTime(2026, 7, 16, 14, 0), // قبل النطاق
      DateTime(2026, 7, 16, 18, 0), // بعد النطاق
    ],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0),
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30),
  );
  assert(dep4 == null, 'يجب أن يرجع null');

  // ── اختبار خروج 5: مصفوفة فارغة ──
  print('🧪 اختبار خروج 5: مصفوفة فارغة');
  final dep5 = calculator.findDepartureTimestamp(
    timestamps: [],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0),
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30),
  );
  assert(dep5 == null, 'يجب أن يرجع null');

  // ── اختبار خروج 6: بصمات غير مرتبة ──
  print('🧪 اختبار خروج 6: بصمات غير مرتبة');
  final dep6 = calculator.findDepartureTimestamp(
    timestamps: [
      DateTime(2026, 7, 16, 16, 0), // ضمن النطاق لكن ليست الأولى
      DateTime(2026, 7, 16, 17, 0), // خارج النطاق
      DateTime(2026, 7, 16, 15, 10), // ✅ الأولى بعد الترتيب
    ],
    date: date,
    beforeShiftEndTime: DateTime(0, 0, 0, 15, 0),
    afterShiftEndTime: DateTime(0, 0, 0, 16, 30),
  );
  assert(dep6 != null, 'يجب أن يرجع قيمة');
  assert(dep6!.hour == 15 && dep6.minute == 10, 'يجب أن تكون 15:10');

  print('🎉 جميع الاختبارات نجحت (حضور + خروج)!');
  print('');
  print('=' * 50);
  print('    اختبارات دالة حالة الحضور (getAttendanceStatus)');
  print('=' * 50);
  print('');

  // الفترات:
  // beforeShiftStart = 06:30 (بداية الفترة المسموحة قبل الدخول)
  // officialShiftStart = 07:00 (بداية الفترة الرسمية)
  // afterShiftStart = 07:15 (نهاية الفترة المسموحة بعد الدخول)
  // maxAttendance = 08:30 (الحد الأقصى)

  final beforeShift = DateTime(0, 0, 0, 6, 30);
  final officialShift = DateTime(0, 0, 0, 7, 0);
  final afterShift = DateTime(0, 0, 0, 7, 15);
  final maxAtt = DateTime(0, 0, 0, 8, 30);

  // ── اختبار حالة 1: مبكراً (06:45 بين 06:30 و 07:00) ──
  print('🧪 اختبار حالة 1: مبكراً');
  final status1 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 6, 45),
  );
  print('   الوقت: 06:45 → $status1');
  assert(status1 == AttendanceStatus.early, 'يجب أن تكون مبكراً');

  // ── اختبار حالة 2: مبكراً عند الحد (06:30 بالضبط) ──
  print('🧪 اختبار حالة 2: مبكراً عند الحد');
  final status2 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 6, 30),
  );
  print('   الوقت: 06:30 → $status2');
  assert(
    status2 == AttendanceStatus.early,
    'يجب أن تكون مبكراً (حد أدنى مشمول)',
  );

  // ── اختبار حالة 3: مقبول (07:05 بين 07:00 و 07:15) ──
  print('🧪 اختبار حالة 3: مقبول');
  final status3 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 7, 5),
  );
  print('   الوقت: 07:05 → $status3');
  assert(status3 == AttendanceStatus.accepted, 'يجب أن تكون مقبول');

  // ── اختبار حالة 4: مقبول عند الحد (07:00 بالضبط) ──
  print('🧪 اختبار حالة 4: مقبول عند الحد');
  final status4 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 7, 0),
  );
  print('   الوقت: 07:00 → $status4');
  assert(
    status4 == AttendanceStatus.accepted,
    'يجب أن تكون مقبول (حد أدنى مشمول)',
  );

  // ── اختبار حالة 5: متأخر (07:30 بين 07:15 و 08:30) ──
  print('🧪 اختبار حالة 5: متأخر');
  final status5 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 7, 30),
  );
  print('   الوقت: 07:30 → $status5');
  assert(status5 == AttendanceStatus.late_, 'يجب أن تكون متأخر');

  // ── اختبار حالة 6: متأخر عند الحد (07:15 بالضبط) ──
  print('🧪 اختبار حالة 6: متأخر عند الحد');
  final status6 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 7, 15),
  );
  print('   الوقت: 07:15 → $status6');
  assert(
    status6 == AttendanceStatus.late_,
    'يجب أن تكون متأخر (حد أدنى مشمول)',
  );

  // ── اختبار حالة 7: غائب (08:30 = الحد الأقصى بالضبط) ──
  print('🧪 اختبار حالة 7: غائب عند الحد الأقصى');
  final status7 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 8, 30),
  );
  print('   الوقت: 08:30 → $status7');
  assert(
    status7 == AttendanceStatus.absent,
    'يجب أن تكون غائب (الحد الأقصى غير مشمول)',
  );

  // ── اختبار حالة 8: غائب (09:00 بعد الحد الأقصى) ──
  print('🧪 اختبار حالة 8: غائب بعد الحد');
  final status8 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 9, 0),
  );
  print('   الوقت: 09:00 → $status8');
  assert(status8 == AttendanceStatus.absent, 'يجب أن تكون غائب');

  // ── اختبار حالة 9: غائب (06:00 قبل الفترة المسموحة) ──
  print('🧪 اختبار حالة 9: غائب قبل الفترة المسموحة');
  final status9 = CalculateTime.getAttendanceStatus(
    beforeShiftStartTime: beforeShift,
    officialShiftStartTime: officialShift,
    afterShiftStartTime: afterShift,
    maxAttendanceTime: maxAtt,
    date: date,
    timestamp: DateTime(2026, 7, 16, 6, 0),
  );
  print('   الوقت: 06:00 → $status9');
  assert(
    status9 == AttendanceStatus.absent,
    'يجب أن تكون غائب (قبل الفترة المسموحة)',
  );

  print('');
  print('🎉 جميع الاختبارات نجحت (حضور + خروج + حالة الحضور)!');
  print('');
  print('=' * 50);
  print('    اختبارات دالة ساعات العمل (calculateWorkingHours)');
  print('=' * 50);
  print('');

  // بيانات الوردية:
  // beforeShiftStart = 06:30, shiftStart = 07:00, afterShiftStart = 07:15
  // maxAttendance = 08:30
  // beforeShiftEnd = 14:30, shiftEnd = 15:00, afterShiftEnd = 15:30
  final shift = ShiftData(
    beforeShiftStart: DateTime(0, 0, 0, 6, 30),
    shiftStart: DateTime(0, 0, 0, 7, 0),
    afterShiftStart: DateTime(0, 0, 0, 7, 15),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
    beforeShiftEnd: DateTime(0, 0, 0, 14, 30),
    shiftEnd: DateTime(0, 0, 0, 15, 0),
    afterShiftEnd: DateTime(0, 0, 0, 15, 30),
    allowOvertime: true,
  );

  // ── اختبار ساعات 1: حضور وانصراف ضمن الفترة الرسمية (بدون إضافي) ──
  print('🧪 اختبار ساعات 1: ضمن الفترة الرسمية');
  final hours1 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0), // 07:00
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    shiftData: shift,
  );
  print('   حضور: 07:00 → انصراف: 15:00 = ${hours1.inHours} ساعات');
  assert(hours1.inHours == 8, 'يجب أن تكون 8 ساعات');

  // ── اختبار ساعات 2: حضور مبكر مع إزالة الإضافي ──
  print('🧪 اختبار ساعات 2: حضور مبكر (إزالة الإضافي)');
  final hours2 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 6, 30), // 06:30 (مبكر 30 دقيقة)
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    shiftData: shift,
  );
  print('   حضور: 06:30 → انصراف: 15:00 = ${hours2.inHours} ساعات');
  assert(hours2.inHours == 8, 'يجب أن تكون 8 ساعات (إزالة 30 دقيقة إضافي)');

  // ── اختبار ساعات 3: انصراف متأخر مع إزالة الإضافي ──
  print('🧪 اختبار ساعات 3: انصراف متأخر (إزالة الإضافي)');
  final hours3 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0), // 07:00
    departureTime: DateTime(0, 0, 0, 15, 30), // 15:30 (متأخر 30 دقيقة)
    date: date,
    shiftData: shift,
  );
  print('   حضور: 07:00 → انصراف: 15:30 = ${hours3.inHours} ساعات');
  assert(hours3.inHours == 8, 'يجب أن تكون 8 ساعات (إزالة 30 دقيقة إضافي)');

  // ── اختبار ساعات 4: حضور مبكر + انصراف متأخر مع إزالة الإضافي ──
  print('🧪 اختبار ساعات 4: مبكر + متأخر (إزالة الإضافي)');
  final hours4 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 6, 30), // 06:30
    departureTime: DateTime(0, 0, 0, 15, 30), // 15:30
    date: date,
    shiftData: shift,
  );
  print('   حضور: 06:30 → انصراف: 15:30 = ${hours4.inHours} ساعات');
  assert(hours4.inHours == 8, 'يجب أن تكون 8 ساعات (إزالة ساعة إضافي)');

  // ── اختبار ساعات 5: بدون إضافي (allowOvertime = false) ──
  print('🧪 اختبار ساعات 5: بدون إزالة الإضافي');
  final shiftNoOvertime = ShiftData(
    beforeShiftStart: DateTime(0, 0, 0, 6, 30),
    shiftStart: DateTime(0, 0, 0, 7, 0),
    afterShiftStart: DateTime(0, 0, 0, 7, 15),
    maxAttendanceTime: DateTime(0, 0, 0, 8, 30),
    beforeShiftEnd: DateTime(0, 0, 0, 14, 30),
    shiftEnd: DateTime(0, 0, 0, 15, 0),
    afterShiftEnd: DateTime(0, 0, 0, 15, 30),
    allowOvertime: false,
  );
  final hours5 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 6, 30), // 06:30
    departureTime: DateTime(0, 0, 0, 15, 30), // 15:30
    date: date,
    shiftData: shiftNoOvertime,
  );
  print('   حضور: 06:30 → انصراف: 15:30 = ${hours5.inHours} ساعات');
  assert(hours5.inHours == 9, 'يجب أن تكون 9 ساعات (بدون إزالة الإضافي)');

  // ── اختبار ساعات 6: حضور فارغ ──
  print('🧪 اختبار ساعات 6: حضور فارغ');
  final hours6 = CalculateTime.calculateWorkingHours(
    attendanceTime: null,
    departureTime: DateTime(0, 0, 0, 15, 0),
    date: date,
    shiftData: shift,
  );
  print('   حضور: null → انصراف: 15:00 = ${hours6.inMinutes} دقائق');
  assert(hours6 == Duration.zero, 'يجب أن يرجع 0');

  // ── اختبار ساعات 7: انصراف فارغ ──
  print('🧪 اختبار ساعات 7: انصراف فارغ');
  final hours7 = CalculateTime.calculateWorkingHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0),
    departureTime: null,
    date: date,
    shiftData: shift,
  );
  print('   حضور: 07:00 → انصراف: null = ${hours7.inMinutes} دقائق');
  assert(hours7 == Duration.zero, 'يجب أن يرجع 0');

  print('');
  print('🎉 جميع الاختبارات نجحت (حضور + خروج + حالة + ساعات عمل + إضافي)!');
  print('');
  print('=' * 50);
  print('    اختبارات الفترة المتجاوزة (calculateExcessHours)');
  print('=' * 50);
  print('');

  final afterShiftEndTime = DateTime(0, 0, 0, 15, 30); // 15:30

  // ── اختبار تجاوز 1: انصراف بعد نهاية الوردية بـ 30 دقيقة ──
  print('🧪 اختبار تجاوز 1: انصراف 16:00 (تجاوز 30 دقيقة)');
  final ex1 = CalculateTime.calculateExcessHours(
    departureTime: DateTime(0, 0, 0, 16, 0), // 16:00
    date: date,
    afterShiftEndTime: afterShiftEndTime,
  );
  print(
    '   انصراف: 16:00 → بعد نهاية الفترة: 15:30 = ${ex1.inMinutes} دقيقة تجاوز',
  );
  assert(ex1.inMinutes == 30, 'يجب أن تكون 30 دقيقة');

  // ── اختبار تجاوز 2: انصراف ضمن الوردية (بدون تجاوز) ──
  print('🧪 اختبار تجاوز 2: انصراف 15:00 (بدون تجاوز)');
  final ex2 = CalculateTime.calculateExcessHours(
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    afterShiftEndTime: afterShiftEndTime,
  );
  print('   انصراف: 15:00 → ${ex2.inMinutes} دقيقة تجاوز');
  assert(ex2 == Duration.zero, 'يجب أن تكون 0');

  // ── اختبار تجاوز 3: انصراف يساوي بعد نهاية الفترة (بدون تجاوز) ──
  print('🧪 اختبار تجاوز 3: انصراف = بعد نهاية الفترة');
  final ex3 = CalculateTime.calculateExcessHours(
    departureTime: DateTime(0, 0, 0, 15, 30), // 15:30
    date: date,
    afterShiftEndTime: afterShiftEndTime,
  );
  print('   انصراف: 15:30 → ${ex3.inMinutes} دقيقة تجاوز');
  assert(ex3 == Duration.zero, 'يجب أن تكون 0 (الحد غير متجاوز)');

  // ── اختبار تجاوز 4: تجاوز كبير (ساعتين) ──
  print('🧪 اختبار تجاوز 4: تجاوز ساعتين');
  final ex4 = CalculateTime.calculateExcessHours(
    departureTime: DateTime(0, 0, 0, 17, 30), // 17:30
    date: date,
    afterShiftEndTime: afterShiftEndTime,
  );
  print('   انصراف: 17:30 → ${ex4.inMinutes} دقيقة تجاوز');
  assert(ex4.inHours == 2, 'يجب أن تكون ساعتين');

  // ── اختبار تجاوز 5: حقل فارغ ──
  print('🧪 اختبار تجاوز 5: حقل فارغ');
  final ex5 = CalculateTime.calculateExcessHours(
    departureTime: null,
    date: date,
    afterShiftEndTime: afterShiftEndTime,
  );
  assert(ex5 == Duration.zero, 'يجب أن تكون 0');

  print('');
  print('🎉 اختبارات التجاوز نجحت!');
  print('');
  print('=' * 50);
  print('    اختبارات دالة ساعات الغياب (calculateAbsenceHours)');
  print('=' * 50);
  print('');

  // الوردية الرسمية: 07:00 → 15:00 = 8 ساعات

  // ── اختبار غياب 1: غياب كامل (حضور فارغ) ──
  print('🧪 اختبار غياب 1: غياب كامل (حضور فارغ)');
  final abs1 = CalculateTime.calculateAbsenceHours(
    attendanceTime: null,
    departureTime: DateTime(0, 0, 0, 15, 0),
    date: date,
    shiftData: shift,
  );
  print('   حضور: null → غياب: ${abs1.inHours} ساعات');
  assert(abs1.inHours == 8, 'يجب أن تكون 8 ساعات (غياب كامل)');

  // ── اختبار غياب 2: غياب كامل (انصراف فارغ) ──
  print('🧪 اختبار غياب 2: غياب كامل (انصراف فارغ)');
  final abs2 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0),
    departureTime: null,
    date: date,
    shiftData: shift,
  );
  print('   انصراف: null → غياب: ${abs2.inHours} ساعات');
  assert(abs2.inHours == 8, 'يجب أن تكون 8 ساعات (غياب كامل)');

  // ── اختبار غياب 3: بدون غياب (حضور كامل) ──
  print('🧪 اختبار غياب 3: بدون غياب');
  final abs3 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0), // 07:00
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    shiftData: shift,
  );
  print('   حضور: 07:00 → انصراف: 15:00 = ${abs3.inMinutes} دقيقة غياب');
  assert(abs3 == Duration.zero, 'يجب أن تكون 0 (بدون غياب)');

  // ── اختبار غياب 4: تأخير ساعة ──
  print('🧪 اختبار غياب 4: تأخير ساعة');
  final abs4 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 8, 0), // 08:00 (متأخر ساعة)
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    shiftData: shift,
  );
  print('   حضور: 08:00 → انصراف: 15:00 = ${abs4.inHours} ساعة غياب');
  assert(abs4.inHours == 1, 'يجب أن تكون ساعة واحدة');

  // ── اختبار غياب 5: انصراف مبكر ساعة ──
  print('🧪 اختبار غياب 5: انصراف مبكر ساعة');
  final abs5 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 7, 0), // 07:00
    departureTime: DateTime(0, 0, 0, 14, 0), // 14:00 (مبكر ساعة)
    date: date,
    shiftData: shift,
  );
  print('   حضور: 07:00 → انصراف: 14:00 = ${abs5.inHours} ساعة غياب');
  assert(abs5.inHours == 1, 'يجب أن تكون ساعة واحدة');

  // ── اختبار غياب 6: تأخير + انصراف مبكر ──
  print('🧪 اختبار غياب 6: تأخير + انصراف مبكر');
  final abs6 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 8, 0), // 08:00 (متأخر ساعة)
    departureTime: DateTime(0, 0, 0, 14, 0), // 14:00 (مبكر ساعة)
    date: date,
    shiftData: shift,
  );
  print('   حضور: 08:00 → انصراف: 14:00 = ${abs6.inHours} ساعات غياب');
  assert(abs6.inHours == 2, 'يجب أن تكون ساعتين');

  // ── اختبار غياب 7: حضور مبكر لا يقلل الغياب ──
  print('🧪 اختبار غياب 7: حضور مبكر لا يغير الغياب');
  final abs7 = CalculateTime.calculateAbsenceHours(
    attendanceTime: DateTime(0, 0, 0, 6, 30), // 06:30 (مبكر)
    departureTime: DateTime(0, 0, 0, 15, 0), // 15:00
    date: date,
    shiftData: shift,
  );
  print('   حضور: 06:30 → انصراف: 15:00 = ${abs7.inMinutes} دقيقة غياب');
  assert(abs7 == Duration.zero, 'يجب أن تكون 0 (المبكر لا يُحسب)');

  print('');
  print('🎉 جميع الاختبارات نجحت!');
}
