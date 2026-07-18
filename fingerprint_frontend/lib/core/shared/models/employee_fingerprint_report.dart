class EmployeeFingerprintReport {
  final int employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime? punch1;
  final DateTime? punch2;
  final DateTime? punch3;
  final DateTime? punch4;
  final DateTime? punch5;
  final DateTime? punch6;

  const EmployeeFingerprintReport({
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.punch1,
    this.punch2,
    this.punch3,
    this.punch4,
    this.punch5,
    this.punch6,
  });

  factory EmployeeFingerprintReport.fromMap(Map<String, dynamic> map) {
    return EmployeeFingerprintReport(
      employeeId: map['employee_id'] as int? ?? 0,
      employeeName: map['employee_name'] as String? ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      punch1: map['punch1'] != null
          ? DateTime.tryParse(map['punch1'].toString())
          : null,
      punch2: map['punch2'] != null
          ? DateTime.tryParse(map['punch2'].toString())
          : null,
      punch3: map['punch3'] != null
          ? DateTime.tryParse(map['punch3'].toString())
          : null,
      punch4: map['punch4'] != null
          ? DateTime.tryParse(map['punch4'].toString())
          : null,
      punch5: map['punch5'] != null
          ? DateTime.tryParse(map['punch5'].toString())
          : null,
      punch6: map['punch6'] != null
          ? DateTime.tryParse(map['punch6'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'date': date.toIso8601String().split('T')[0],
      'punch1': punch1?.toIso8601String(),
      'punch2': punch2?.toIso8601String(),
      'punch3': punch3?.toIso8601String(),
      'punch4': punch4?.toIso8601String(),
      'punch5': punch5?.toIso8601String(),
      'punch6': punch6?.toIso8601String(),
    };
  }
}
