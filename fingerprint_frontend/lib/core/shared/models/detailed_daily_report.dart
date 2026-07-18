class DetailedDailyReport {
  final int employeeId;
  final String employeeName;
  final DateTime? date;
  final String? shiftName;
  final DateTime? attendanceTime;
  final DateTime? departureTime;
  final double workHours;
  final double overtimeHours;
  final double absenceHours;
  final String? attendanceStatus;

  const DetailedDailyReport({
    required this.employeeId,
    required this.employeeName,
    this.date,
    this.shiftName,
    this.attendanceTime,
    this.departureTime,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.absenceHours = 0,
    this.attendanceStatus,
  });

  factory DetailedDailyReport.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    if (map['date'] != null) {
      parsedDate = DateTime.tryParse(map['date'].toString());
    }
    return DetailedDailyReport(
      employeeId: map['employee_id'] as int? ?? 0,
      employeeName: map['employee_name'] as String? ?? '',
      date: parsedDate,
      shiftName: map['shift_name'] as String?,
      attendanceTime: map['attendance_time'] != null
          ? DateTime.tryParse(map['attendance_time'].toString())
          : null,
      departureTime: map['departure_time'] != null
          ? DateTime.tryParse(map['departure_time'].toString())
          : null,
      workHours: (map['work_hours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble() ?? 0,
      absenceHours: (map['absence_hours'] as num?)?.toDouble() ?? 0,
      attendanceStatus: map['attendance_status'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': date?.toIso8601String(),
      'shift_name': shiftName,
      'attendance_time': attendanceTime?.toIso8601String(),
      'departure_time': departureTime?.toIso8601String(),
      'work_hours': workHours,
      'overtime_hours': overtimeHours,
      'absence_hours': absenceHours,
      'attendance_status': attendanceStatus,
    };
  }
}
