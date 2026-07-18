class CalculateTime {
  /// دالة مساعدة: تدمج وقت مع تاريخ.
  /// في الوردية الليلية، إذا كان الوقت أصغر من ساعة بداية الوردية
  /// يُضاف يوم واحد (لأنه ينتمي لليوم التالي).
  static DateTime _mergeTimeWithDate(
    DateTime time,
    DateTime date, {
    bool isNightShift = false,
    int shiftStartHour = 0,
  }) {
    var merged = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
    if (isNightShift && time.hour < shiftStartHour) {
      merged = merged.add(const Duration(days: 1));
    }
    return merged;
  }
  /// تبحث عن أول بصمة حضور تقع ضمن نطاق بداية الوردية والحد الأقصى للحضور.
  ///
  /// [timestamps] - مصفوفة من DateTime تمثل أوقات البصمات.
  /// [date] - تاريخ اليوم (بدون وقت).
  /// [shiftStartTime] - وقت بداية فترة الوردية (بدون تاريخ).
  /// [maxAttendanceTime] - الحد الأقصى للحضور (بدون تاريخ).
  ///
  /// يرجع أول DateTime مطابق أو null إذا لم يوجد.
  static DateTime? findMatchingTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime shiftStartTime,
    required DateTime maxAttendanceTime,
  }) {
    if (timestamps.isEmpty) return null;
    // دمج الوقت مع التاريخ
    final shiftStart = _mergeTimeWithDate(shiftStartTime, date);
    final maxAttendance = _mergeTimeWithDate(
      maxAttendanceTime,
      date,
      isNightShift: maxAttendanceTime.hour < shiftStartTime.hour,
      shiftStartHour: shiftStartTime.hour,
    );
    // ترتيب المصفوفة تصاعدياً
    final sorted = List<DateTime>.from(timestamps)..sort();
    // المرور على كل قيمة والبحث عن مطابقة
    for (final timestamp in sorted) {
      if (timestamp.isAtSameMomentAs(shiftStart) ||
          (timestamp.isAfter(shiftStart) &&
              timestamp.isBefore(maxAttendance))) {
        return timestamp;
      }
    }
    // لم يتم العثور على قيمة مطابقة
    return null;
  }

  /// تبحث عن أول بصمة خروج تقع ضمن نطاق نهاية الوردية.
  ///
  /// [timestamps] - مصفوفة من DateTime تمثل أوقات البصمات.
  /// [date] - تاريخ اليوم (بدون وقت).
  /// [beforeShiftEndTime] - وقت قبل نهاية الفترة (بدون تاريخ).
  /// [afterShiftEndTime] - وقت بعد نهاية الفترة (بدون تاريخ).
  /// [isNightShift] - هل هي وردية ليلية.
  /// [shiftStartHour] - ساعة بداية الوردية (للوردية الليلية).
  ///
  /// الشرط: القيمة > beforeShiftEnd و <= afterShiftEnd
  /// يرجع أول DateTime مطابق أو null إذا لم يوجد.
  static DateTime? findDepartureTimestamp({
    required List<DateTime> timestamps,
    required DateTime date,
    required DateTime beforeShiftEndTime,
    required DateTime afterShiftEndTime,
    bool isNightShift = false,
    int shiftStartHour = 0,
  }) {
    if (timestamps.isEmpty) return null;

    // دمج الوقت مع التاريخ (مع دعم الوردية الليلية)
    final beforeShiftEnd = _mergeTimeWithDate(
      beforeShiftEndTime, date,
      isNightShift: isNightShift, shiftStartHour: shiftStartHour,
    );
    final afterShiftEnd = _mergeTimeWithDate(
      afterShiftEndTime, date,
      isNightShift: isNightShift, shiftStartHour: shiftStartHour,
    );

    // ترتيب المصفوفة تصاعدياً
    final sorted = List<DateTime>.from(timestamps)..sort();

    // المرور على كل قيمة والبحث عن مطابقة
    for (final timestamp in sorted) {
      if (timestamp.isAfter(beforeShiftEnd) &&
          (timestamp.isBefore(afterShiftEnd) ||
              timestamp.isAtSameMomentAs(afterShiftEnd))) {
        return timestamp;
      }
    }

    // لم يتم العثور على قيمة مطابقة
    return null;
  }

  /// تحدد حالة الحضور بناءً على الوقت المراد مطابقته.
  ///
  /// [beforeShiftStartTime] - الفترة المسموحة قبل الدخول الرسمي (وقت فقط).
  /// [officialShiftStartTime] - بداية الفترة الرسمية (وقت فقط).
  /// [afterShiftStartTime] - الفترة المسموحة بعد الدخول الرسمي (وقت فقط).
  /// [maxAttendanceTime] - الحد الأقصى للحضور (وقت فقط).
  /// [date] - التاريخ (تاريخ فقط).
  /// [timestamp] - الوقت المراد مطابقته.
  ///
  /// المطابقة:
  /// - مبكراً: beforeShiftStart <= timestamp < officialShiftStart
  /// - مقبول: officialShiftStart <= timestamp < afterShiftStart
  /// - متأخر: afterShiftStart <= timestamp < maxAttendance
  /// - غائب: خارج جميع النطاقات
  static AttendanceStatus getAttendanceStatus({
    required DateTime beforeShiftStartTime,
    required DateTime officialShiftStartTime,
    required DateTime afterShiftStartTime,
    required DateTime maxAttendanceTime,
    required DateTime date,
    required DateTime timestamp,
  }) {
    // دمج جميع حقول الوقت مع التاريخ
    final beforeShiftStart = _mergeTimeWithDate(beforeShiftStartTime, date);
    final officialShiftStart = _mergeTimeWithDate(officialShiftStartTime, date);
    final afterShiftStart = _mergeTimeWithDate(afterShiftStartTime, date);
    final maxAttendance = _mergeTimeWithDate(maxAttendanceTime, date);

    // مبكراً: beforeShiftStart <= timestamp < officialShiftStart
    if ((timestamp.isAtSameMomentAs(beforeShiftStart) ||
            timestamp.isAfter(beforeShiftStart)) &&
        timestamp.isBefore(officialShiftStart)) {
      return AttendanceStatus.early;
    }

    // مقبول: officialShiftStart <= timestamp < afterShiftStart
    if ((timestamp.isAtSameMomentAs(officialShiftStart) ||
            timestamp.isAfter(officialShiftStart)) &&
        timestamp.isBefore(afterShiftStart)) {
      return AttendanceStatus.accepted;
    }

    // متأخر: afterShiftStart <= timestamp < maxAttendance
    if ((timestamp.isAtSameMomentAs(afterShiftStart) ||
            timestamp.isAfter(afterShiftStart)) &&
        timestamp.isBefore(maxAttendance)) {
      return AttendanceStatus.late_;
    }

    // غائب
    return AttendanceStatus.absent;
  }

  /// تحسب عدد ساعات العمل الفعلية.
  ///
  /// [attendanceTime] - وقت حضور الموظف (وقت فقط)، null = غائب.
  /// [departureTime] - وقت انصراف الموظف (وقت فقط)، null = غائب.
  /// [date] - التاريخ (تاريخ فقط).
  /// [shiftData] - بيانات الوردية.
  ///
  /// يتم تقييد الحضور والانصراف ضمن نطاق الوردية
  /// [beforeShiftStart, afterShiftEnd] ثم حساب الفارق.
  /// إذا كانت الوردية تسمح بفترة إضافي يتم إزالتها
  /// (الفترة خارج [shiftStart, shiftEnd]).
  static Duration calculateWorkingHours({
    required DateTime? attendanceTime,
    required DateTime? departureTime,
    required DateTime date,
    required ShiftData shiftData,
  }) {
    // إذا كان أحد الحقلين فارغاً يرجع 0
    if (attendanceTime == null || departureTime == null) {
      return Duration.zero;
    }

    final isNight = shiftData.isNightShift;
    final startHour = shiftData.shiftStart.hour;

    // دمج وقت الحضور والانصراف مع التاريخ
    var attendance = _mergeTimeWithDate(
      attendanceTime, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );
    var departure = _mergeTimeWithDate(
      departureTime, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );

    // دمج حقول الوردية مع التاريخ
    final beforeStart = _mergeTimeWithDate(
      shiftData.beforeShiftStart, date,
    );
    final afterEnd = _mergeTimeWithDate(
      shiftData.afterShiftEnd, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );
    final officialStart = _mergeTimeWithDate(
      shiftData.shiftStart, date,
    );
    final officialEnd = _mergeTimeWithDate(
      shiftData.shiftEnd, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );

    // تقييد ضمن نطاق الوردية [beforeShiftStart, afterShiftEnd]
    if (attendance.isBefore(beforeStart)) attendance = beforeStart;
    if (departure.isAfter(afterEnd)) departure = afterEnd;

    // إذا كان الانصراف قبل أو يساوي الحضور
    if (departure.isBefore(attendance) ||
        departure.isAtSameMomentAs(attendance)) {
      return Duration.zero;
    }

    var totalDuration = departure.difference(attendance);

    // إزالة فترة الإضافي إذا كانت الوردية تسمح بذلك
    if (shiftData.allowOvertime) {
      // الفترة الإضافية قبل البداية الرسمية
      if (attendance.isBefore(officialStart)) {
        final clampedEnd = departure.isBefore(officialStart)
            ? departure
            : officialStart;
        final earlyOvertime = clampedEnd.difference(attendance);
        totalDuration -= earlyOvertime;
      }

      // الفترة الإضافية بعد النهاية الرسمية
      if (departure.isAfter(officialEnd)) {
        final clampedStart = attendance.isAfter(officialEnd)
            ? attendance
            : officialEnd;
        final lateOvertime = departure.difference(clampedStart);
        totalDuration -= lateOvertime;
      }
    }

    // ضمان عدم إرجاع قيمة سالبة
    if (totalDuration.isNegative) return Duration.zero;

    return totalDuration;
  }

  /// تحسب الفترة التي تتعدى نهاية الوردية (بعد حقل بعد نهاية الفترة).
  ///
  /// [departureTime] - وقت انصراف الموظف (وقت فقط)، null = لا يوجد.
  /// [date] - التاريخ (تاريخ فقط).
  /// [afterShiftEndTime] - حقل بعد نهاية الفترة (وقت فقط).
  ///
  /// إذا كان وقت الانصراف > afterShiftEnd يرجع الفارق، وإلا يرجع Duration.zero.
  static Duration calculateExcessHours({
    required DateTime? departureTime,
    required DateTime date,
    required DateTime afterShiftEndTime,
  }) {
    if (departureTime == null) return Duration.zero;

    // دمج مع التاريخ
    final departure = _mergeTimeWithDate(departureTime, date);
    final afterShiftEnd = _mergeTimeWithDate(afterShiftEndTime, date);

    // إذا كان الانصراف بعد حقل بعد نهاية الفترة
    if (departure.isAfter(afterShiftEnd)) {
      return departure.difference(afterShiftEnd);
    }

    return Duration.zero;
  }

  /// تحسب عدد ساعات الغياب.
  ///
  /// [attendanceTime] - وقت حضور الموظف (وقت فقط)، null = غائب.
  /// [departureTime] - وقت انصراف الموظف (وقت فقط)، null = غائب.
  /// [date] - التاريخ (تاريخ فقط).
  /// [shiftData] - بيانات الوردية.
  ///
  /// إذا كان أحد الحقلين فارغاً: الغياب = shiftEnd - shiftStart (كامل الوردية).
  /// وإلا: الغياب = مدة الوردية الرسمية - الفترة الفعلية ضمن الوردية الرسمية.
  static Duration calculateAbsenceHours({
    required DateTime? attendanceTime,
    required DateTime? departureTime,
    required DateTime date,
    required ShiftData shiftData,
  }) {
    final isNight = shiftData.isNightShift;
    final startHour = shiftData.shiftStart.hour;

    // دمج حقول الوردية الرسمية مع التاريخ
    final officialStart = _mergeTimeWithDate(
      shiftData.shiftStart, date,
    );
    final officialEnd = _mergeTimeWithDate(
      shiftData.shiftEnd, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );

    // مدة الوردية الرسمية الكاملة
    final officialShiftDuration = officialEnd.difference(officialStart);

    // إذا كان أحد الحقلين فارغاً → غياب كامل
    if (attendanceTime == null || departureTime == null) {
      return officialShiftDuration;
    }

    // دمج وقت الحضور والانصراف مع التاريخ
    final attendance = _mergeTimeWithDate(
      attendanceTime, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );
    final departure = _mergeTimeWithDate(
      departureTime, date,
      isNightShift: isNight, shiftStartHour: startHour,
    );

    // حساب التقاطع بين فترة الحضور والفترة الرسمية
    // overlapStart = max(attendance, officialStart)
    final overlapStart = attendance.isAfter(officialStart)
        ? attendance
        : officialStart;

    // overlapEnd = min(departure, officialEnd)
    final overlapEnd = departure.isBefore(officialEnd)
        ? departure
        : officialEnd;

    // إذا لا يوجد تقاطع → غياب كامل
    if (overlapEnd.isBefore(overlapStart) ||
        overlapEnd.isAtSameMomentAs(overlapStart)) {
      return officialShiftDuration;
    }

    // الفترة الفعلية ضمن الوردية الرسمية
    final actualWorkInShift = overlapEnd.difference(overlapStart);

    // الغياب = مدة الوردية - الفترة الفعلية
    final absence = officialShiftDuration - actualWorkInShift;

    return absence.isNegative ? Duration.zero : absence;
  }
}

/// حالات الحضور
enum AttendanceStatus {
  /// مبكراً - حضر قبل الوقت الرسمي
  early,

  /// مقبول - حضر في الوقت الرسمي
  accepted,

  /// متأخر - حضر بعد الوقت الرسمي وقبل الحد الأقصى
  late_,

  /// غائب - لم يحضر ضمن أي نطاق مسموح
  absent,
}

/// بيانات الوردية
class ShiftData {
  /// بداية الفترة الرسمية (وقت فقط)
  final DateTime shiftStart;

  /// نهاية الفترة الرسمية (وقت فقط)
  final DateTime shiftEnd;

  /// قبل بداية الفترة - الفترة المسموحة قبل الدخول (وقت فقط)
  final DateTime beforeShiftStart;

  /// بعد بداية الفترة - الفترة المسموحة بعد الدخول (وقت فقط)
  final DateTime afterShiftStart;

  /// الحد الأقصى للحضور (وقت فقط)
  final DateTime maxAttendanceTime;

  /// قبل نهاية الفترة (وقت فقط)
  final DateTime beforeShiftEnd;

  /// بعد نهاية الفترة (وقت فقط)
  final DateTime afterShiftEnd;

  /// هل الوردية تسمح بفترة إضافي
  final bool allowOvertime;

  /// هل هي وردية ليلية (تمتد بين يومين)
  final bool isNightShift;

  const ShiftData({
    required this.shiftStart,
    required this.shiftEnd,
    required this.beforeShiftStart,
    required this.afterShiftStart,
    required this.maxAttendanceTime,
    required this.beforeShiftEnd,
    required this.afterShiftEnd,
    required this.allowOvertime,
    this.isNightShift = false,
  });
}
