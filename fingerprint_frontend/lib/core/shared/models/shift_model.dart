import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import '../entities/shift_entity.dart';
import '../enums/week_days_enum.dart';

final class ShiftModel extends ShiftEntity {
  const ShiftModel({
    required super.id,
    required super.name,
    required super.startTime,
    required super.endTime,
    required super.beforeStartTime,
    required super.afterStartTime,
    required super.beforeEndTime,
    required super.afterEndTime,
    required super.maxAttendanceTime,
    super.weekendDays,
    super.isNightShift,
    super.acceptOvertime,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    final rawWeekend = map['weekend_days'];
    List<WeekDays>? weekendDays;
    if (rawWeekend is List) {
      weekendDays = WeekDays.fromValues(
        rawWeekend.map((e) => e as int).toList(),
      );
    }

    return ShiftModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      startTime: toTime(map['start_time']),
      endTime: toTime(map['end_time']),
      beforeStartTime: toTime(map['before_start_time']),
      afterStartTime: toTime(map['after_start_time']),
      beforeEndTime: toTime(map['before_end_time']),
      afterEndTime: toTime(map['after_end_time']),
      maxAttendanceTime: toTime(map['max_attendance_time']),
      weekendDays: weekendDays,
      isNightShift: map['is_night_shift'] as bool? ?? false,
      acceptOvertime: map['accept_overtime'] as bool? ?? true,
    );
  }

  factory ShiftModel.fromEntity(ShiftEntity entity) {
    return ShiftModel(
      id: entity.id,
      name: entity.name,
      startTime: entity.startTime,
      endTime: entity.endTime,
      beforeStartTime: entity.beforeStartTime,
      afterStartTime: entity.afterStartTime,
      beforeEndTime: entity.beforeEndTime,
      afterEndTime: entity.afterEndTime,
      maxAttendanceTime: entity.maxAttendanceTime,
      weekendDays: entity.weekendDays,
      isNightShift: entity.isNightShift,
      acceptOvertime: entity.acceptOvertime,
    );
  }

  ShiftEntity toEntity() {
    return ShiftEntity(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      beforeStartTime: beforeStartTime,
      afterStartTime: afterStartTime,
      beforeEndTime: beforeEndTime,
      afterEndTime: afterEndTime,
      maxAttendanceTime: maxAttendanceTime,
      weekendDays: weekendDays,
      isNightShift: isNightShift,
      acceptOvertime: acceptOvertime,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    final map = <String, dynamic>{
      if (!removeId) 'id': id,
      'name': name,
      'start_time':
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')}',
      'end_time':
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:${endTime.second.toString().padLeft(2, '0')}',
      'before_start_time':
          '${beforeStartTime.hour.toString().padLeft(2, '0')}:${beforeStartTime.minute.toString().padLeft(2, '0')}:${beforeStartTime.second.toString().padLeft(2, '0')}',
      'after_start_time':
          '${afterStartTime.hour.toString().padLeft(2, '0')}:${afterStartTime.minute.toString().padLeft(2, '0')}:${afterStartTime.second.toString().padLeft(2, '0')}',
      'before_end_time':
          '${beforeEndTime.hour.toString().padLeft(2, '0')}:${beforeEndTime.minute.toString().padLeft(2, '0')}:${beforeEndTime.second.toString().padLeft(2, '0')}',
      'after_end_time':
          '${afterEndTime.hour.toString().padLeft(2, '0')}:${afterEndTime.minute.toString().padLeft(2, '0')}:${afterEndTime.second.toString().padLeft(2, '0')}',
      'max_attendance_time':
          '${maxAttendanceTime.hour.toString().padLeft(2, '0')}:${maxAttendanceTime.minute.toString().padLeft(2, '0')}:${maxAttendanceTime.second.toString().padLeft(2, '0')}',
      'is_night_shift': isNightShift,
      'accept_overtime': acceptOvertime,
    };
    if (weekendDays != null) {
      map['weekend_days'] = WeekDays.toValues(weekendDays!);
    }
    return map;
  }

  @override
  ShiftModel copyWith({
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
    return ShiftModel(
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
