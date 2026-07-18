import 'package:flutter/material.dart';

enum AttendanceReviewStatus {
  excellent,
  acceptable,
  late,
  absent;

  String get label {
    switch (this) {
      case AttendanceReviewStatus.excellent:
        return 'ممتاز';
      case AttendanceReviewStatus.acceptable:
        return 'مقبول';
      case AttendanceReviewStatus.late:
        return 'متأخر';
      case AttendanceReviewStatus.absent:
        return 'غائب';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceReviewStatus.excellent:
        return const Color(0xFF0E9F6E);
      case AttendanceReviewStatus.acceptable:
        return const Color(0xFF1A56DB);
      case AttendanceReviewStatus.late:
        return const Color(0xFFE3A008);
      case AttendanceReviewStatus.absent:
        return const Color(0xFFF05252);
    }
  }

  Color get background {
    switch (this) {
      case AttendanceReviewStatus.excellent:
        return const Color(0xFFD1FAE5);
      case AttendanceReviewStatus.acceptable:
        return const Color(0xFFDBE1FF);
      case AttendanceReviewStatus.late:
        return const Color(0xFFFEF3C7);
      case AttendanceReviewStatus.absent:
        return const Color(0xFFFFE5E5);
    }
  }
}

class DailyAttendanceEmployeeReport {
  final int employeeId;
  final String employeeName;
  final DateTime date;
  final String? shiftName;
  final String? shiftStartTime;
  final String? shiftEndTime;
  final String? beforeStartTime;
  final String? afterStartTime;
  final String? beforeEndTime;
  final String? afterEndTime;
  final DateTime? firstPunchDateTime;
  final DateTime? lastPunchDateTime;
  final double totalHours;
  final int punchCount;

  const DailyAttendanceEmployeeReport({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.shiftName,
    this.shiftStartTime,
    this.shiftEndTime,
    this.beforeStartTime,
    this.afterStartTime,
    this.beforeEndTime,
    this.afterEndTime,
    this.firstPunchDateTime,
    this.lastPunchDateTime,
    this.totalHours = 0,
    this.punchCount = 0,
  });

  factory DailyAttendanceEmployeeReport.fromMap(Map<String, dynamic> map) {
    return DailyAttendanceEmployeeReport(
      employeeId: map['employee_id'] as int? ?? 0,
      employeeName: map['employee_name'] as String? ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      shiftName: map['shift_name'] as String?,
      shiftStartTime: map['shift_start_time'] as String?,
      shiftEndTime: map['shift_end_time'] as String?,
      beforeStartTime: map['before_start_time'] as String?,
      afterStartTime: map['after_start_time'] as String?,
      beforeEndTime: map['before_end_time'] as String?,
      afterEndTime: map['after_end_time'] as String?,
      firstPunchDateTime: map['first_punch_datetime'] != null
          ? DateTime.tryParse(map['first_punch_datetime'].toString())
          : null,
      lastPunchDateTime: map['last_punch_datetime'] != null
          ? DateTime.tryParse(map['last_punch_datetime'].toString())
          : null,
      totalHours: (map['total_hours'] as num?)?.toDouble() ?? 0,
      punchCount: (map['punch_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': date.toIso8601String().split('T')[0],
      'shift_name': shiftName,
      'shift_start_time': shiftStartTime,
      'shift_end_time': shiftEndTime,
      'before_start_time': beforeStartTime,
      'after_start_time': afterStartTime,
      'before_end_time': beforeEndTime,
      'after_end_time': afterEndTime,
      'first_punch_datetime': firstPunchDateTime?.toIso8601String(),
      'last_punch_datetime': lastPunchDateTime?.toIso8601String(),
      'total_hours': totalHours,
      'punch_count': punchCount,
    };
  }

  AttendanceReviewStatus? get status {
    if (punchCount == 0) return AttendanceReviewStatus.absent;
    if (punchCount == 1) return AttendanceReviewStatus.absent;
    if (shiftStartTime == null || firstPunchDateTime == null) return null;

    final parts = shiftStartTime!.split(':');
    if (parts.length < 2) return null;
    final shiftStart = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );

    final firstPunch = firstPunchDateTime!;

    if (!firstPunch.isAfter(shiftStart)) {
      return AttendanceReviewStatus.excellent;
    }

    // Use afterStartTime as grace window if available
    if (afterStartTime != null) {
      final graceParts = afterStartTime!.split(':');
      if (graceParts.length >= 2) {
        final graceEnd = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(graceParts[0]),
          int.parse(graceParts[1]),
          graceParts.length > 2 ? int.parse(graceParts[2]) : 0,
        );
        if (!firstPunch.isAfter(graceEnd)) {
          return AttendanceReviewStatus.acceptable;
        }
      }
    }

    const lateThresholdMinutes = 45;
    final lateThreshold = shiftStart.add(
      const Duration(minutes: lateThresholdMinutes),
    );
    if (!firstPunch.isAfter(lateThreshold)) return AttendanceReviewStatus.late;

    return AttendanceReviewStatus.late;
  }

  AttendanceReviewStatus? get lastPunchStatus {
    if (punchCount == 0) return AttendanceReviewStatus.absent;
    if (punchCount == 1) return AttendanceReviewStatus.absent;
    if (shiftEndTime == null || lastPunchDateTime == null) return null;

    final parts = shiftEndTime!.split(':');
    if (parts.length < 2) return null;
    var shiftEnd = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );

    if (shiftStartTime != null) {
      final startParts = shiftStartTime!.split(':');
      if (startParts.length >= 2 && shiftEnd.hour < int.parse(startParts[0])) {
        shiftEnd = shiftEnd.add(const Duration(days: 1));
      }
    }

    final lastPunch = lastPunchDateTime!;

    if (!lastPunch.isBefore(shiftEnd)) return AttendanceReviewStatus.excellent;

    // Use beforeEndTime as grace window if available
    if (beforeEndTime != null) {
      final graceParts = beforeEndTime!.split(':');
      if (graceParts.length >= 2) {
        final graceStart = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(graceParts[0]),
          int.parse(graceParts[1]),
          graceParts.length > 2 ? int.parse(graceParts[2]) : 0,
        );
        if (!lastPunch.isBefore(graceStart)) {
          return AttendanceReviewStatus.acceptable;
        }
      }
    }

    return AttendanceReviewStatus.late;
  }

  String get formattedFirstPunchTime {
    if (firstPunchDateTime == null) return '----';
    final h = firstPunchDateTime!.hour;
    final m = firstPunchDateTime!.minute;
    final s = firstPunchDateTime!.second;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '${hour12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} $period';
  }

  String get formattedLastPunchTime {
    if (lastPunchDateTime == null) return '----';
    final h = lastPunchDateTime!.hour;
    final m = lastPunchDateTime!.minute;
    final s = lastPunchDateTime!.second;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '${hour12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} $period';
  }

  String get formattedTotalHours {
    if (totalHours <= 0) return '00:00 ساعة';
    final hours = totalHours.toInt();
    final minutes = ((totalHours - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} ساعة';
  }
}
