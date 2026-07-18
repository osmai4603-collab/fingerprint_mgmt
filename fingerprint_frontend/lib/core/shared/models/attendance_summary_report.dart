class AttendanceSummaryReport {
  final int employeeId;
  final String employeeName;
  final double workHours;
  final double overtimeHours;
  final double absenceHours;
  final double deductionAmount;

  const AttendanceSummaryReport({
    required this.employeeId,
    required this.employeeName,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.absenceHours = 0,
    this.deductionAmount = 0,
  });

  factory AttendanceSummaryReport.fromMap(Map<String, dynamic> map) {
    return AttendanceSummaryReport(
      employeeId: map['employee_id'] as int? ?? 0,
      employeeName: map['employee_name'] as String? ?? '',
      workHours: (map['work_hours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (map['overtime_hours'] as num?)?.toDouble() ?? 0,
      absenceHours: (map['absence_hours'] as num?)?.toDouble() ?? 0,
      deductionAmount: (map['deduction_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'work_hours': workHours,
      'overtime_hours': overtimeHours,
      'absence_hours': absenceHours,
      'deduction_amount': deductionAmount,
    };
  }
}
