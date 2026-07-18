import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_records_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final EmployeeRepository _employeeRepo;
  final ShiftsRepository _shiftsRepo;
  final BiometricDevicesRepository _devicesRepo;
  final AttendanceRecordsRepository _attendanceRecordsRepo;
  final AttendanceLogsRepository _attendanceLogsRepo;

  DashboardBloc(
    this._employeeRepo,
    this._shiftsRepo,
    this._devicesRepo,
    this._attendanceRecordsRepo,
    this._attendanceLogsRepo,
  ) : super(const DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final futures = <Future<dynamic>>[
        _employeeRepo.get().then((r) => r.getOrElse(() => <EmployeeEntity>[])),
        _shiftsRepo.get().then((r) => r.getOrElse(() => <ShiftEntity>[])),
        _devicesRepo.get().then((r) => r.getOrElse(() => <BiometricDeviceEntity>[])),
        _attendanceRecordsRepo.getAttendanceSummaryReport(from: monthStart, to: now)
            .then((r) => r.getOrElse(() => <AttendanceSummaryReport>[])),
        _attendanceRecordsRepo.getAttendanceOnlyReport(from: todayStart, to: now)
            .then((r) => r.getOrElse(() => <DetailedDailyReport>[])),
        _attendanceRecordsRepo.getAbsenceOnlyReport(from: todayStart, to: now)
            .then((r) => r.getOrElse(() => <DetailedDailyReport>[])),
        _attendanceRecordsRepo.getLateAttendanceReport(from: todayStart, to: now)
            .then((r) => r.getOrElse(() => <DetailedDailyReport>[])),
        _attendanceRecordsRepo.getLateAttendanceReport(from: monthStart, to: now)
            .then((r) => r.getOrElse(() => <DetailedDailyReport>[])),
        _attendanceLogsRepo.getAttendanceLogs(fromDate: todayStart, toDate: now)
            .then((r) => r.getOrElse(() => <AttendanceLogModel>[])),
      ];

      final results = await Future.wait(futures);

      final employeeList = results[0] as List<EmployeeEntity>;
      final shiftList = results[1] as List<ShiftEntity>;
      final deviceList = results[2] as List<BiometricDeviceEntity>;
      final summaryList = results[3] as List<AttendanceSummaryReport>;
      final presentTodayList = results[4] as List<DetailedDailyReport>;
      final absentTodayList = results[5] as List<DetailedDailyReport>;
      final lateTodayList = results[6] as List<DetailedDailyReport>;
      final lateMonthList = results[7] as List<DetailedDailyReport>;
      final logsList = results[8] as List<AttendanceLogModel>;

      final sortedByAbsence = List<AttendanceSummaryReport>.from(summaryList)
        ..sort((a, b) => b.absenceHours.compareTo(a.absenceHours));
      final mostAbsent = sortedByAbsence.take(5).toList();

      final sortedByWork = List<AttendanceSummaryReport>.from(summaryList)
        ..sort((a, b) => b.workHours.compareTo(a.workHours));
      final mostPresent = sortedByWork.take(5).toList();

      final lateCounts = HashMap<String, int>();
      for (final r in lateMonthList) {
        lateCounts[r.employeeName] = (lateCounts[r.employeeName] ?? 0) + 1;
      }
      final sortedLate = lateCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final mostLate = sortedLate.take(5).map((e) => LateEmployeeSummary(
        employeeName: e.key,
        lateCount: e.value,
      )).toList();

      emit(DashboardLoaded(
        employeeCount: employeeList.length,
        activeEmployeeCount: employeeList.where((e) => e.isActive).length,
        shiftCount: shiftList.length,
        deviceCount: deviceList.length,
        presentToday: presentTodayList.length,
        absentToday: absentTodayList.length,
        lateToday: lateTodayList.length,
        mostAbsent: mostAbsent,
        mostPresent: mostPresent,
        mostLate: mostLate,
        recentActivity: logsList.take(5).toList(),
      ));
    } catch (e) {
      emit(DashboardError('فشل تحميل البيانات: $e'));
    }
  }
}
