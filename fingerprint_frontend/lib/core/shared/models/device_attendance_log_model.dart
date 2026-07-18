class DeviceAttendanceLog {
  final String userId;
  final int status;
  final int punchType;
  final DateTime? timestamp;

  const DeviceAttendanceLog({
    required this.userId,
    required this.status,
    required this.punchType,
    this.timestamp,
  });

  factory DeviceAttendanceLog.fromMap(Map<String, dynamic> map) {
    return DeviceAttendanceLog(
      userId: map['user_id']?.toString() ?? '',
      status: map['status'] as int? ?? -1,
      punchType: map['punch_type'] as int? ?? -1,
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp'] as DateTime
          : DateTime.tryParse(map['timestamp']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'status': status,
      'punch_type': punchType,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
