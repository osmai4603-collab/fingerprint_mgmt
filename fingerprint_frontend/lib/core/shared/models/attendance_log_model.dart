import '../entities/attendance_log_entity.dart';
import 'employee_model.dart';

class AttendanceLogModel extends AttendanceLogEntity {
  const AttendanceLogModel({
    required super.id,
    super.unrecognizedBiometric,
    super.employeeId,
    super.deviceId,
    required super.punchTime,
    super.employee,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLogModel(
      id: json['id'] as int? ?? 0,
      unrecognizedBiometric: json['unrecognized_biometric'] as String?,
      employeeId: json['employee_id'] as int?,
      deviceId: json['device_id'] as int?,
      punchTime: json['punch_time'] is DateTime
          ? json['punch_time'] as DateTime
          : DateTime.parse(json['punch_time'].toString()),
      employee: json['employee'] != null
          ? EmployeeModel.fromMap(json['employee'] as Map<String, dynamic>)
          : null,
    );
  }

  factory AttendanceLogModel.fromEntity(AttendanceLogEntity entity) {
    return AttendanceLogModel(
      id: entity.id,
      unrecognizedBiometric: entity.unrecognizedBiometric,
      employeeId: entity.employeeId,
      deviceId: entity.deviceId,
      punchTime: entity.punchTime,
      employee: entity.employee,
    );
  }

  AttendanceLogEntity toEntity() {
    return AttendanceLogEntity(
      id: id,
      unrecognizedBiometric: unrecognizedBiometric,
      employeeId: employeeId,
      deviceId: deviceId,
      punchTime: punchTime,
      employee: employee,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId) 'id': id,
      'unrecognized_biometric': unrecognizedBiometric,
      'employee_id': employeeId,
      'device_id': deviceId,
      'punch_time': punchTime.toUtc().toString(),
      if (employee != null) 'employee': (employee as EmployeeModel?)?.toMap(),
    };
  }
}
