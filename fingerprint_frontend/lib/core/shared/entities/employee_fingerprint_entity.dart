import 'package:fingerprint_frontend/core/shared/entities/entity.dart';

class EmployeeFingerprintEntity extends Entity {
  final int id;
  final int employeeId;
  final String biometric;
  final int fingerIndex;

  const EmployeeFingerprintEntity({
    required this.id,
    required this.employeeId,
    required this.biometric,
    this.fingerIndex = 0,
  });

  @override
  List<Object?> get props => [id, employeeId, biometric, fingerIndex];

  @override
  EmployeeFingerprintEntity copyWith({
    int? id,
    int? employeeId,
    String? biometric,
    int? fingerIndex,
  }) {
    return EmployeeFingerprintEntity(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      biometric: biometric ?? this.biometric,
      fingerIndex: fingerIndex ?? this.fingerIndex,
    );
  }
}
