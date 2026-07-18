import 'package:fingerprint_frontend/core/shared/entities/entity.dart';

import '../enums/week_days_enum.dart';

/// Represents a shift with its timings and rules
class ShiftEntity extends Entity {
  final int id;
  final String name;
  final DateTime startTime; // format 'HH:mm:ss'
  final DateTime endTime; // format 'HH:mm:ss'
  final DateTime beforeStartTime;
  final DateTime afterStartTime;
  final DateTime beforeEndTime;
  final DateTime afterEndTime;
  final DateTime maxAttendanceTime;
  final List<WeekDays>? weekendDays;
  final bool isNightShift;
  final bool acceptOvertime;

  const ShiftEntity({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.beforeStartTime,
    required this.afterStartTime,
    required this.beforeEndTime,
    required this.afterEndTime,
    required this.maxAttendanceTime,
    this.weekendDays,
    this.isNightShift = false,
    this.acceptOvertime = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    startTime.toUtc().toString(),
    endTime.toUtc().toString(),
    beforeStartTime.toUtc().toString(),
    afterStartTime.toUtc().toString(),
    beforeEndTime.toUtc().toString(),
    afterEndTime.toUtc().toString(),
    maxAttendanceTime.toUtc().toString(),
    weekendDays,
    isNightShift,
    acceptOvertime,
  ];

  @override
  ShiftEntity copyWith({
    int? id,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? beforeStartTime,
    DateTime? afterStartTime,
    DateTime? beforeEndTime,
    DateTime? afterEndTime,
    DateTime? maxAttendanceTime,
    List<WeekDays>? weekendDays,
    bool? isNightShift,
    bool? acceptOvertime,
  }) {
    return ShiftEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      beforeStartTime: beforeStartTime ?? this.beforeStartTime,
      afterStartTime: afterStartTime ?? this.afterStartTime,
      beforeEndTime: beforeEndTime ?? this.beforeEndTime,
      afterEndTime: afterEndTime ?? this.afterEndTime,
      maxAttendanceTime: maxAttendanceTime ?? this.maxAttendanceTime,
      weekendDays: weekendDays ?? this.weekendDays,
      isNightShift: isNightShift ?? this.isNightShift,
      acceptOvertime: acceptOvertime ?? this.acceptOvertime,
    );
  }
}
