import 'package:fingerprint_frontend/core/shared/enums/biometric_device_type.dart';

import '../entities/biometric_device_entity.dart';

final class BiometricDeviceModel extends BiometricDeviceEntity {
  const BiometricDeviceModel({
    required super.id,
    required super.name,
    required super.ipAddress,
    super.port,
    required super.deviceType,
    super.isOnline,
    super.lastSync,
    super.lastRequestDate,
  });

  factory BiometricDeviceModel.fromMap(Map<String, dynamic> data) {
    return BiometricDeviceModel(
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      ipAddress: data['ip_address'] as String,
      port: data['port'] as int? ?? 4370,
      deviceType: BiometricDeviceType.of(data['device_type'] as String),
      isOnline: data['is_online'] as bool? ?? false,
      lastSync: data['last_sync'] != null
          ? (data['last_sync'] is DateTime
                ? data['last_sync'] as DateTime
                : DateTime.tryParse(data['last_sync'].toString()))
          : null,
      lastRequestDate: data['last_request_date'] != null
          ? (data['last_request_date'] is DateTime
                ? data['last_request_date'] as DateTime
                : DateTime.tryParse(data['last_request_date'].toString()))
          : null,
    );
  }

  factory BiometricDeviceModel.fromEntity(BiometricDeviceEntity entity) {
    return BiometricDeviceModel(
      id: entity.id,
      name: entity.name,
      ipAddress: entity.ipAddress,
      port: entity.port,
      deviceType: entity.deviceType,
      isOnline: entity.isOnline,
      lastSync: entity.lastSync,
      lastRequestDate: entity.lastRequestDate,
    );
  }

  BiometricDeviceEntity toEntity() {
    return BiometricDeviceEntity(
      id: id,
      name: name,
      ipAddress: ipAddress,
      port: port,
      deviceType: deviceType,
      isOnline: isOnline,
      lastSync: lastSync,
      lastRequestDate: lastRequestDate,
    );
  }

  Map<String, dynamic> toMap({bool removeId = false}) {
    return {
      if (!removeId) 'id': id,
      'name': name,
      'ip_address': ipAddress,
      'port': port,
      'device_type': deviceType.name,
      'is_online': isOnline,
      'last_sync': lastSync?.toIso8601String(),
      'last_request_date': lastRequestDate?.toIso8601String(),
    };
  }

  @override
  BiometricDeviceModel copyWith({
    int? id,
    String? name,
    String? ipAddress,
    int? port,
    BiometricDeviceType? deviceType,
    bool? isOnline,
    DateTime? lastSync,
    DateTime? lastRequestDate,
  }) {
    return BiometricDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      deviceType: deviceType ?? this.deviceType,
      isOnline: isOnline ?? this.isOnline,
      lastSync: lastSync ?? this.lastSync,
      lastRequestDate: lastRequestDate ?? this.lastRequestDate,
    );
  }
}
