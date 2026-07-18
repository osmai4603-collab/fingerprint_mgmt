import '../entities/device_sync_result_entity.dart';

final class DeviceSyncResultModel extends DeviceSyncResultEntity {
  const DeviceSyncResultModel({
    required super.deviceId,
    required super.deviceName,
    required super.totalPunches,
    required super.uniqueEmployees,
    super.firstPunchTime,
    super.lastPunchTime,
    super.lastSync,
  });

  factory DeviceSyncResultModel.fromMap(Map<String, dynamic> map) {
    return DeviceSyncResultModel(
      deviceId: map['deviceId'] as int? ?? 0,
      deviceName: map['deviceName'] as String? ?? '',
      totalPunches: map['totalPunches'] as int? ?? 0,
      uniqueEmployees: map['uniqueEmployees'] as int? ?? 0,
      firstPunchTime: map['firstPunchTime'] != null ? DateTime.parse(map['firstPunchTime'] as String) : null,
      lastPunchTime: map['lastPunchTime'] != null ? DateTime.parse(map['lastPunchTime'] as String) : null,
      lastSync: map['lastSync'] != null ? DateTime.parse(map['lastSync'] as String) : null,
    );
  }

  factory DeviceSyncResultModel.fromEntity(DeviceSyncResultEntity entity) {
    return DeviceSyncResultModel(
      deviceId: entity.deviceId,
      deviceName: entity.deviceName,
      totalPunches: entity.totalPunches,
      uniqueEmployees: entity.uniqueEmployees,
      firstPunchTime: entity.firstPunchTime,
      lastPunchTime: entity.lastPunchTime,
      lastSync: entity.lastSync,
    );
  }

  DeviceSyncResultEntity toEntity() {
    return DeviceSyncResultEntity(
      deviceId: deviceId,
      deviceName: deviceName,
      totalPunches: totalPunches,
      uniqueEmployees: uniqueEmployees,
      firstPunchTime: firstPunchTime,
      lastPunchTime: lastPunchTime,
      lastSync: lastSync,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'totalPunches': totalPunches,
      'uniqueEmployees': uniqueEmployees,
      'firstPunchTime': firstPunchTime?.toIso8601String(),
      'lastPunchTime': lastPunchTime?.toIso8601String(),
      'lastSync': lastSync?.toIso8601String(),
    };
  }

  @override
  DeviceSyncResultModel copyWith({
    int? deviceId,
    String? deviceName,
    int? totalPunches,
    int? uniqueEmployees,
    DateTime? firstPunchTime,
    DateTime? lastPunchTime,
    DateTime? lastSync,
  }) {
    return DeviceSyncResultModel(
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
