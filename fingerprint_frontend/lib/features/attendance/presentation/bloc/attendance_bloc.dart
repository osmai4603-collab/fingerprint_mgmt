import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

// --- Events ---
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class LoadRawLogsEvent extends AttendanceEvent {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? employeeId;
  final bool unrecognizedOnly;
  const LoadRawLogsEvent({
    this.fromDate,
    this.toDate,
    this.employeeId,
    this.unrecognizedOnly = false,
  });
  @override
  List<Object?> get props => [fromDate, toDate, employeeId, unrecognizedOnly];
}

class LinkUnrecognizedLogEvent extends AttendanceEvent {
  final int logId;
  final int employeeId;
  const LinkUnrecognizedLogEvent({
    required this.logId,
    required this.employeeId,
  });
  @override
  List<Object?> get props => [logId, employeeId];
}

class AddManualPunchEvent extends AttendanceEvent {
  final int employeeId;
  final DateTime punchTime;
  final int? deviceId;
  const AddManualPunchEvent({
    required this.employeeId,
    required this.punchTime,
    this.deviceId,
  });
  @override
  List<Object?> get props => [employeeId, punchTime, deviceId];
}

class CreateAttendanceLogEvent extends AttendanceEvent {
  final AttendanceLogEntity log;
  const CreateAttendanceLogEvent({required this.log});
  @override
  List<Object?> get props => [log];
}

// --- States ---
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceRawLogsLoaded extends AttendanceState {
  final List<AttendanceLogModel> logs;
  const AttendanceRawLogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;
  const AttendanceOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceLogsRepository _logsRepository;

  AttendanceBloc(this._logsRepository) : super(const AttendanceInitial()) {
    on<LoadRawLogsEvent>(_onLoadAttendanceLogs);
    on<LinkUnrecognizedLogEvent>(_onLinkLog);
    on<AddManualPunchEvent>(_onAddManualPunch);
    on<CreateAttendanceLogEvent>(_onCreateAttendanceLog);
  }

  Future<void> _onLoadAttendanceLogs(
    LoadRawLogsEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    final result = await _logsRepository.getAttendanceLogs(
      employeeId: event.employeeId,
      fromDate: event.fromDate,
      toDate: event.toDate,
      unrecognizedOnly: event.unrecognizedOnly,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (logs) => emit(AttendanceRawLogsLoaded(logs)),
    );
  }

  Future<void> _onLinkLog(
    LinkUnrecognizedLogEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    final result = await _logsRepository.linkLog(event.logId, event.employeeId);
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) =>
          emit(const AttendanceOperationSuccess('تم ربط البصمة بالموظف بنجاح')),
    );
  }

  Future<void> _onAddManualPunch(
    AddManualPunchEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    final result = await _logsRepository.addManualPunch(
      event.employeeId,
      event.punchTime,
      deviceId: event.deviceId,
    );
    result.fold(
      (failure) => emit(AttendanceError(failure.message)),
      (_) => emit(
        const AttendanceOperationSuccess('تم إضافة البصمة اليدوية بنجاح'),
      ),
    );
  }

  Future<void> _onCreateAttendanceLog(
    CreateAttendanceLogEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    final result = await _logsRepository.create(event.log);
    result.fold((failure) => emit(AttendanceError(failure.message)), (_) {
      emit(const AttendanceOperationSuccess('تم إنشاء سجل الحضور بنجاح'));
      add(LoadRawLogsEvent());
    });
  }
}
