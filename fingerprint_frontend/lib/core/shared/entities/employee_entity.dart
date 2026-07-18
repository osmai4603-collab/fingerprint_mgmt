import 'package:fingerprint_frontend/core/shared/entities/entity.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class EmployeeEntity extends Entity {
  final int uid;
  final String employeeID;
  final String name;
  final EmployeeRole role;
  final String? password;
  final String? groupId;
  final int? cardNo;
  final int? defaultShiftId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ShiftEntity? shift;

  const EmployeeEntity({
    required this.uid,
    required this.employeeID,
    required this.name,
    this.role = EmployeeRole.user,
    this.password,
    this.groupId,
    this.cardNo,
    this.defaultShiftId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.shift,
  });

  @override
  List<Object?> get props => [
    uid,
    employeeID,
    name,
    role,
    password,
    groupId,
    cardNo,
    defaultShiftId,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  EmployeeEntity copyWith({
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
    return EmployeeEntity(
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
