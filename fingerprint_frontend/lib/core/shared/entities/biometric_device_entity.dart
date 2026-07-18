import 'package:fingerprint_frontend/core/shared/entities/entity.dart';
import 'package:fingerprint_frontend/core/shared/enums/biometric_device_type.dart';

/// Represents a biometric device registered in the system
class BiometricDeviceEntity extends Entity {
  final int id;
  final String name;
  final String ipAddress;
  final int port;
  final BiometricDeviceType deviceType;
  final bool isOnline;
  final DateTime? lastSync;
  final DateTime? lastRequestDate;

  const BiometricDeviceEntity({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.port = 4370,
    required this.deviceType,
    this.isOnline = false,
    this.lastSync,
    this.lastRequestDate,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    ipAddress,
    port,
    deviceType,
    isOnline,
    lastSync,
    lastRequestDate,
  ];

  @override
  BiometricDeviceEntity copyWith({
    int? id,
    String? name,
    String? ipAddress,
    int? port,
    BiometricDeviceType? deviceType,
    bool? isOnline,
    DateTime? lastSync,
    DateTime? lastRequestDate,
  }) {
    return BiometricDeviceEntity(
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
