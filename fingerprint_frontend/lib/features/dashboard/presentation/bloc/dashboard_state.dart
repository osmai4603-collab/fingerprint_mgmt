import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class LateEmployeeSummary {
  final String employeeName;
  final int lateCount;

  const LateEmployeeSummary({
    required this.employeeName,
    required this.lateCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LateEmployeeSummary &&
          runtimeType == other.runtimeType &&
          employeeName == other.employeeName &&
          lateCount == other.lateCount;

  @override
  int get hashCode => employeeName.hashCode ^ lateCount.hashCode;
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final int employeeCount;
  final int activeEmployeeCount;
  final int shiftCount;
  final int deviceCount;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final List<AttendanceSummaryReport> mostAbsent;
  final List<AttendanceSummaryReport> mostPresent;
  final List<LateEmployeeSummary> mostLate;
  final List<AttendanceLogModel> recentActivity;

  const DashboardLoaded({
    required this.employeeCount,
    required this.activeEmployeeCount,
    required this.shiftCount,
    required this.deviceCount,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.mostAbsent,
    required this.mostPresent,
    required this.mostLate,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
    employeeCount,
    activeEmployeeCount,
    shiftCount,
    deviceCount,
    presentToday,
    absentToday,
    lateToday,
    mostAbsent,
    mostPresent,
    mostLate,
    recentActivity,
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
