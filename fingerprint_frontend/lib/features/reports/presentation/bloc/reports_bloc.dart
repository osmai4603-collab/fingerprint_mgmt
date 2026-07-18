import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_records_repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

enum ReportType {
  fingerprint,
  summary,
  detailed,
  attendanceOnly,
  absenceOnly,
  late,
  absenceWithDeductions;

  String get label {
    switch (this) {
      case ReportType.fingerprint:
        return 'بصمات الموظفين';
      case ReportType.summary:
        return 'ملخص الدوام';
      case ReportType.detailed:
        return 'تفصيلي يومي';
      case ReportType.attendanceOnly:
        return 'الحضور فقط';
      case ReportType.absenceOnly:
        return 'الغياب فقط';
      case ReportType.late:
        return 'المتأخرين';
      case ReportType.absenceWithDeductions:
        return 'الغياب مع الخصومات';
    }
  }
}

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportEvent extends ReportsEvent {
  final ReportType reportType;
  final DateTime from;
  final DateTime to;
  final int? employeeId;

  const LoadReportEvent({
    required this.reportType,
    required this.from,
    required this.to,
    this.employeeId,
  });

  @override
  List<Object?> get props => [reportType, from, to, employeeId];
}

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final ReportType reportType;
  final List<dynamic> data;
  final String label;

  const ReportsLoaded({
    required this.reportType,
    required this.data,
    required this.label,
  });

  @override
  List<Object?> get props => [reportType, data, label];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final AttendanceRecordsRepository _repository;

  ReportsBloc(this._repository) : super(const ReportsInitial()) {
    on<LoadReportEvent>(_onLoadReport);
  }

  Future<void> _onLoadReport(
    LoadReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    Either<Failure, dynamic> result;

    switch (event.reportType) {
      case ReportType.fingerprint:
        result = await _repository.getEmployeeFingerprintReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.summary:
        result = await _repository.getAttendanceSummaryReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.detailed:
        result = await _repository.getDetailedDailyReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.attendanceOnly:
        result = await _repository.getAttendanceOnlyReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.absenceOnly:
        result = await _repository.getAbsenceOnlyReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.late:
        result = await _repository.getLateAttendanceReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
      case ReportType.absenceWithDeductions:
        result = await _repository.getAbsenceWithDeductionsReport(
          from: event.from,
          to: event.to,
          employeeId: event.employeeId,
        );
        break;
    }

    result.fold(
      (failure) => emit(ReportsError(failure.message)),
      (data) {
        final list = data as List<dynamic>;
        emit(ReportsLoaded(
          reportType: event.reportType,
          data: list,
          label: event.reportType.label,
        ));
      },
    );
  }
}
