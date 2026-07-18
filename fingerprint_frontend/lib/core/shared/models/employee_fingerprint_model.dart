import 'package:fingerprint_frontend/core/shared/entities/entity.dart';

import '../entities/employee_fingerprint_entity.dart';

final class EmployeeFingerprintModel extends EmployeeFingerprintEntity {
  const EmployeeFingerprintModel({
    required super.id,
    required super.employeeId,
    required super.biometric,
    super.fingerIndex,
  });

  factory EmployeeFingerprintModel.fromMap(Map<String, dynamic> map) {
    return EmployeeFingerprintModel(
      id: map['id'] as int? ?? 0,
      employeeId: map['employee_id'] as int? ?? 0,
      biometric: map['biometric'] as String? ?? '',
      fingerIndex: map['finger_index'] as int? ?? 0,
    );
  }

  factory EmployeeFingerprintModel.fromEntity(EmployeeFingerprintEntity entity) {
    return EmployeeFingerprintModel(
      id: entity.id,
      employeeId: entity.employeeId,
      biometric: entity.biometric,
      fingerIndex: entity.fingerIndex,
    );
  }

  EmployeeFingerprintEntity toEntity() {
    return EmployeeFingerprintEntity(
      id: id,
      employeeId: employeeId,
      biometric: biometric,
      fingerIndex: fingerIndex,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId) 'id': id,
      'employee_id': employeeId,
      'biometric': biometric,
      'finger_index': fingerIndex,
    };
  }

  @override
  EmployeeFingerprintModel copyWith({
    int? id,
    int? employeeId,
    String? biometric,
    int? fingerIndex,
  }) {
    return EmployeeFingerprintModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      biometric: biometric ?? this.biometric,
      fingerIndex: fingerIndex ?? this.fingerIndex,
    );
  }
}

class EmployeeSummaryEntity extends Entity {
  final int employeeUid;
  final String employeeId;
  final String name;
  final double totalWorkingHours;
  final int totalLateMins;
  final int totalOvertimeMins;
  final int fingerprintCount;
  final String? shiftName;

  const EmployeeSummaryEntity({
    required this.employeeUid,
    required this.employeeId,
    required this.name,
    this.totalWorkingHours = 0.0,
    this.totalLateMins = 0,
    this.totalOvertimeMins = 0,
    this.fingerprintCount = 0,
    this.shiftName,
  });

  @override
  List<Object?> get props => [
        employeeUid,
        employeeId,
        name,
        totalWorkingHours,
        totalLateMins,
        totalOvertimeMins,
        fingerprintCount,
        shiftName,
      ];

  @override
  EmployeeSummaryEntity copyWith({
    int? employeeUid,
    String? employeeId,
    String? name,
    double? totalWorkingHours,
    int? totalLateMins,
    int? totalOvertimeMins,
    int? fingerprintCount,
    String? shiftName,
  }) {
    return EmployeeSummaryEntity(
      employeeUid: employeeUid ?? this.employeeUid,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      totalWorkingHours: totalWorkingHours ?? this.totalWorkingHours,
      totalLateMins: totalLateMins ?? this.totalLateMins,
      totalOvertimeMins: totalOvertimeMins ?? this.totalOvertimeMins,
      fingerprintCount: fingerprintCount ?? this.fingerprintCount,
      shiftName: shiftName ?? this.shiftName,
    );
  }
}

final class EmployeeSummaryModel extends EmployeeSummaryEntity {
  const EmployeeSummaryModel({
    required super.employeeUid,
    required super.employeeId,
    required super.name,
    super.totalWorkingHours,
    super.totalLateMins,
    super.totalOvertimeMins,
    super.fingerprintCount,
    super.shiftName,
  });

  factory EmployeeSummaryModel.fromMap(Map<String, dynamic> map) {
    return EmployeeSummaryModel(
      employeeUid: map['employee_uid'] as int? ?? 0,
      employeeId: map['employee_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      totalWorkingHours: (map['total_working_hours'] as num?)?.toDouble() ?? 0.0,
      totalLateMins: map['total_late_mins'] as int? ?? 0,
      totalOvertimeMins: map['total_overtime_mins'] as int? ?? 0,
      fingerprintCount: map['fingerprint_count'] as int? ?? 0,
      shiftName: map['shift_name'] as String?,
    );
  }

  factory EmployeeSummaryModel.fromEntity(EmployeeSummaryEntity entity) {
    return EmployeeSummaryModel(
      employeeUid: entity.employeeUid,
      employeeId: entity.employeeId,
      name: entity.name,
      totalWorkingHours: entity.totalWorkingHours,
      totalLateMins: entity.totalLateMins,
      totalOvertimeMins: entity.totalOvertimeMins,
      fingerprintCount: entity.fingerprintCount,
      shiftName: entity.shiftName,
    );
  }

  EmployeeSummaryEntity toEntity() {
    return EmployeeSummaryEntity(
      employeeUid: employeeUid,
      employeeId: employeeId,
      name: name,
      totalWorkingHours: totalWorkingHours,
      totalLateMins: totalLateMins,
      totalOvertimeMins: totalOvertimeMins,
      fingerprintCount: fingerprintCount,
      shiftName: shiftName,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      'employee_uid': employeeUid,
      'employee_id': employeeId,
      'name': name,
      'total_working_hours': totalWorkingHours,
      'total_late_mins': totalLateMins,
      'total_overtime_mins': totalOvertimeMins,
      'fingerprint_count': fingerprintCount,
      'shift_name': shiftName,
    };
  }
}

class FingerprintSearchResult {
  final bool matched;
  final int? employeeUid;
  final String? employeeName;

  const FingerprintSearchResult({
    required this.matched,
    this.employeeUid,
    this.employeeName,
  });

  factory FingerprintSearchResult.fromMap(Map<String, dynamic> map) {
    return FingerprintSearchResult(
      matched: map['matched'] as bool? ?? false,
      employeeUid: map['employee_uid'] as int?,
      employeeName: map['employee_name'] as String?,
    );
  }
}
