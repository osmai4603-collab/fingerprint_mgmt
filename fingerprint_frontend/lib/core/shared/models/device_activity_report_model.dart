import '../entities/device_activity_report_entity.dart';

final class DeviceActivityReportModel extends DeviceActivityReportEntity {
  const DeviceActivityReportModel({
    required super.deviceId,
    required super.deviceName,
    required super.totalPunches,
    required super.uniqueEmployees,
    required super.stateCounts,
    super.firstPunchTime,
    super.lastPunchTime,
  });

  factory DeviceActivityReportModel.fromMap(Map<String, dynamic> map) {
    return DeviceActivityReportModel(
      deviceId: map['deviceId'] as int? ?? 0,
      deviceName: map['deviceName'] as String? ?? '',
      totalPunches: map['totalPunches'] as int? ?? 0,
      uniqueEmployees: map['uniqueEmployees'] as int? ?? 0,
      stateCounts: (map['stateCounts'] as Map?)?.cast<String, int>() ?? <String, int>{},
      firstPunchTime: map['firstPunchTime'] != null ? DateTime.parse(map['firstPunchTime'] as String) : null,
      lastPunchTime: map['lastPunchTime'] != null ? DateTime.parse(map['lastPunchTime'] as String) : null,
    );
  }

  factory DeviceActivityReportModel.fromEntity(DeviceActivityReportEntity entity) {
    return DeviceActivityReportModel(
      deviceId: entity.deviceId,
      deviceName: entity.deviceName,
      totalPunches: entity.totalPunches,
      uniqueEmployees: entity.uniqueEmployees,
      stateCounts: entity.stateCounts,
      firstPunchTime: entity.firstPunchTime,
      lastPunchTime: entity.lastPunchTime,
    );
  }

  DeviceActivityReportEntity toEntity() {
    return DeviceActivityReportEntity(
      deviceId: deviceId,
      deviceName: deviceName,
      totalPunches: totalPunches,
      uniqueEmployees: uniqueEmployees,
      stateCounts: stateCounts,
      firstPunchTime: firstPunchTime,
      lastPunchTime: lastPunchTime,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'totalPunches': totalPunches,
      'uniqueEmployees': uniqueEmployees,
      'stateCounts': stateCounts,
      'firstPunchTime': firstPunchTime?.toIso8601String(),
      'lastPunchTime': lastPunchTime?.toIso8601String(),
    };
  }

  @override
  DeviceActivityReportModel copyWith({
    int? deviceId,
    String? deviceName,
    int? totalPunches,
    int? uniqueEmployees,
    Map<String, int>? stateCounts,
    DateTime? firstPunchTime,
    DateTime? lastPunchTime,
  }) {
    return DeviceActivityReportModel(
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
