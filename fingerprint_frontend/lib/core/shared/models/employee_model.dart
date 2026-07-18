import 'package:fingerprint_frontend/core/shared/shared_core.dart';

final class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.uid,
    required super.employeeID,
    required super.name,
    super.role,
    super.password,
    super.groupId,
    super.cardNo,
    super.defaultShiftId,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.shift,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      uid: map['uid'] as int? ?? 0,
      employeeID: map['employee_id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: EmployeeRole.of(map['role'] as String? ?? 'user'),
      password: map['password'] as String?,
      groupId: map['group_id'] as String?,
      cardNo: map['card_no'] as int?,
      defaultShiftId: map['default_shift_id'] as int?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
      shift: map['shift'] == null ? null : ShiftModel.fromMap(map['shift']),
    );
  }

  factory EmployeeModel.fromEntity(EmployeeEntity entity) {
    return EmployeeModel(
      uid: entity.uid,
      employeeID: entity.employeeID,
      name: entity.name,
      role: entity.role,
      password: entity.password,
      groupId: entity.groupId,
      cardNo: entity.cardNo,
      defaultShiftId: entity.defaultShiftId,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      shift: entity.shift,
    );
  }

  EmployeeEntity toEntity() {
    return EmployeeEntity(
      uid: uid,
      employeeID: employeeID,
      name: name,
      role: role,
      password: password,
      groupId: groupId,
      cardNo: cardNo,
      defaultShiftId: defaultShiftId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      shift: shift,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    final data = {
      if (!removeId) 'uid': uid,
      'employee_id': employeeID,
      'name': name,
      'role': role.name,
      'password': password,
      'group_id': groupId,
      'card_no': cardNo,
      'default_shift_id': defaultShiftId,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toString(),
      'updated_at': updatedAt.toUtc().toString(),
    };
    return data;
  }

  @override
  EmployeeModel copyWith({
    int? uid,
    String? employeeID,
    String? name,
    EmployeeRole? role,
    String? password,
    String? groupId,
    int? cardNo,
    int? defaultShiftId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShiftEntity? shift,
  }) {
    return EmployeeModel(
      uid: uid ?? this.uid,
      employeeID: employeeID ?? this.employeeID,
      name: name ?? this.name,
      role: role ?? this.role,
      password: password ?? this.password,
      groupId: groupId ?? this.groupId,
      cardNo: cardNo ?? this.cardNo,
      defaultShiftId: defaultShiftId ?? this.defaultShiftId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shift: shift ?? this.shift,
    );
  }
}
