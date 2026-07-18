import 'package:fingerprint_frontend/core/shared/entities/entity.dart';

class DeviceSyncResultEntity extends Entity {
  final int deviceId;
  final String deviceName;
  final int totalPunches;
  final int uniqueEmployees;
  final DateTime? firstPunchTime;
  final DateTime? lastPunchTime;
  final DateTime? lastSync;

  const DeviceSyncResultEntity({
    required this.deviceId,
    required this.deviceName,
    required this.totalPunches,
    required this.uniqueEmployees,
    this.firstPunchTime,
    this.lastPunchTime,
    this.lastSync,
  });

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    totalPunches,
    uniqueEmployees,
    firstPunchTime,
    lastPunchTime,
    lastSync,
  ];

  @override
  DeviceSyncResultEntity copyWith({
    int? deviceId,
    String? deviceName,
    int? totalPunches,
    int? uniqueEmployees,
    DateTime? firstPunchTime,
    DateTime? lastPunchTime,
    DateTime? lastSync,
  }) {
    return DeviceSyncResultEntity(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      totalPunches: totalPunches ?? this.totalPunches,
      uniqueEmployees: uniqueEmployees ?? this.uniqueEmployees,
      firstPunchTime: firstPunchTime ?? this.firstPunchTime,
      lastPunchTime: lastPunchTime ?? this.lastPunchTime,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}
