import 'package:fingerprint_frontend/core/shared/entities/entity.dart';
import 'employee_entity.dart';

/// كيان نظيف يمثل بصمة/إدخال حضور خام.
class AttendanceLogEntity extends Entity {
  final int id;
  final String? unrecognizedBiometric;
  final int? employeeId;
  final int? deviceId;
  final DateTime punchTime;
  final EmployeeEntity? employee;

  const AttendanceLogEntity({
    required this.id,
    this.unrecognizedBiometric,
    this.employeeId,
    this.deviceId,
    required this.punchTime,
    this.employee,
  });

  @override
  List<Object?> get props => [
    id,
    unrecognizedBiometric,
    employeeId,
    deviceId,
    punchTime,
    employee,
  ];

  @override
  AttendanceLogEntity copyWith({
    int? id,
    String? unrecognizedBiometric,
    int? employeeId,
    int? deviceId,
    DateTime? punchTime,
    EmployeeEntity? employee,
  }) {
    return AttendanceLogEntity(
      id: id ?? this.id,
      unrecognizedBiometric:
          unrecognizedBiometric ?? this.unrecognizedBiometric,
      employeeId: employeeId ?? this.employeeId,
      deviceId: deviceId ?? this.deviceId,
      punchTime: punchTime ?? this.punchTime,
      employee: employee ?? this.employee,
    );
  }
}
