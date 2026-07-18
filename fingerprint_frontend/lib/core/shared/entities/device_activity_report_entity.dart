import 'package:fingerprint_frontend/core/shared/entities/entity.dart';

class DeviceActivityReportEntity extends Entity {
  final int deviceId;
  final String deviceName;
  final int totalPunches;
  final int uniqueEmployees;
  final Map<String, int> stateCounts;
  final DateTime? firstPunchTime;
  final DateTime? lastPunchTime;

  const DeviceActivityReportEntity({
    required this.deviceId,
    required this.deviceName,
    required this.totalPunches,
    required this.uniqueEmployees,
    this.stateCounts = const <String, int>{},
    this.firstPunchTime,
    this.lastPunchTime,
  });

  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    totalPunches,
    uniqueEmployees,
    stateCounts,
    firstPunchTime,
    lastPunchTime,
  ];

  @override
  DeviceActivityReportEntity copyWith({
    int? deviceId,
    String? deviceName,
    int? totalPunches,
    int? uniqueEmployees,
    Map<String, int>? stateCounts,
    DateTime? firstPunchTime,
    DateTime? lastPunchTime,
  }) {
    return DeviceActivityReportEntity(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      totalPunches: totalPunches ?? this.totalPunches,
      uniqueEmployees: uniqueEmployees ?? this.uniqueEmployees,
      stateCounts: stateCounts ?? this.stateCounts,
      firstPunchTime: firstPunchTime ?? this.firstPunchTime,
      lastPunchTime: lastPunchTime ?? this.lastPunchTime,
    );
  }
}
