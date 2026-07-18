import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';

// Events
abstract class EmployeesEvent extends Equatable {
  const EmployeesEvent();
}

class LoadEmployeesEvent extends EmployeesEvent {
  const LoadEmployeesEvent();
  @override
  List<Object?> get props => [];
}

class CreateEmployeeEvent extends EmployeesEvent {
  final EmployeeEntity employee;
  const CreateEmployeeEvent({required this.employee});
  @override
  List<Object?> get props => [employee];
}

class UpdateEmployeeEvent extends EmployeesEvent {
  final EmployeeEntity employee;
  const UpdateEmployeeEvent({required this.employee});
  @override
  List<Object?> get props => [employee];
}

class ToggleEmployeeStatusEvent extends EmployeesEvent {
  final int employeeId;
  final bool isActive;
  const ToggleEmployeeStatusEvent({
    required this.employeeId,
    required this.isActive,
  });
  @override
  List<Object?> get props => [employeeId, isActive];
}

class DeleteEmployeeEvent extends EmployeesEvent {
  final int employeeId;
  const DeleteEmployeeEvent({required this.employeeId});
  @override
  List<Object?> get props => [employeeId];
}

class FindEmployeeByQueryEvent extends EmployeesEvent {
  final String? employeeId;
  final int? cardNo;
  const FindEmployeeByQueryEvent({this.employeeId, this.cardNo});
  @override
  List<Object?> get props => [employeeId ?? '', cardNo ?? 0];
}

class LoadEmployeeSummaryEvent extends EmployeesEvent {
  final int employeeUid;
  const LoadEmployeeSummaryEvent({required this.employeeUid});
  @override
  List<Object?> get props => [employeeUid];
}

class LoadFingerprintsEvent extends EmployeesEvent {
  final int employeeUid;
  const LoadFingerprintsEvent({required this.employeeUid});
  @override
  List<Object?> get props => [employeeUid];
}

class AddFingerprintEvent extends EmployeesEvent {
  final EmployeeFingerprintEntity entity;
  const AddFingerprintEvent({required this.entity});
  @override
  List<Object?> get props => [entity];
}

class DeleteFingerprintEvent extends EmployeesEvent {
  final int employeeUid;
  final int fingerprintId;
  const DeleteFingerprintEvent({
    required this.employeeUid,
    required this.fingerprintId,
  });
  @override
  List<Object?> get props => [employeeUid, fingerprintId];
}

class SearchByFingerprintEvent extends EmployeesEvent {
  final String biometric;
  const SearchByFingerprintEvent({required this.biometric});
  @override
  List<Object?> get props => [biometric];
}

class ImportCsvEvent extends EmployeesEvent {
  final String csvContent;
  const ImportCsvEvent({required this.csvContent});
  @override
  List<Object?> get props => [csvContent];
}

// States
abstract class EmployeesState extends Equatable {
  const EmployeesState();
}

class EmployeesInitial extends EmployeesState {
  const EmployeesInitial();
  @override
  List<Object?> get props => [];
}

class EmployeesLoading extends EmployeesState {
  const EmployeesLoading();
  @override
  List<Object?> get props => [];
}

class EmployeesLoaded extends EmployeesState {
  final List<EmployeeModel> employees;
  const EmployeesLoaded(this.employees);
  @override
  List<Object?> get props => [employees];
}

class EmployeesOperationSuccess extends EmployeesState {
  final String message;
  const EmployeesOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeesError extends EmployeesState {
  final String message;
  const EmployeesError(this.message);
  @override
  List<Object?> get props => [message];
}

class EmployeeSummaryLoaded extends EmployeesState {
  final EmployeeSummaryModel summary;
  const EmployeeSummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class FingerprintsLoaded extends EmployeesState {
  final List<EmployeeFingerprintModel> fingerprints;
  const FingerprintsLoaded(this.fingerprints);
  @override
  List<Object?> get props => [fingerprints];
}

class FingerprintSearchResultState extends EmployeesState {
  final FingerprintSearchResult result;
  const FingerprintSearchResultState(this.result);
  @override
  List<Object?> get props => [result];
}

class CsvImportResultState extends EmployeesState {
  final int created;
  final int updated;
  final List<String> errors;
  const CsvImportResultState({
    required this.created,
    required this.updated,
    required this.errors,
  });
  @override
  List<Object?> get props => [created, updated, errors];
}

class EmployeeQueryResult extends EmployeesState {
  final EmployeeModel? employee;
  const EmployeeQueryResult(this.employee);
  @override
  List<Object?> get props => [employee];
}

class _EmployeesController {
  List<EmployeeModel> _employees = [];

  List<EmployeeModel> get employees => List.unmodifiable(_employees);

  void loadAll(List<EmployeeModel> data) {
    _employees = List.from(data);
    _employees.sort((a, b) => a.name.compareTo(b.name));
  }

  void put(EmployeeModel employee) {
    final index = _employees.indexWhere((e) => e.uid == employee.uid);
    if (index != -1) {
      _employees[index] = employee;
    } else {
      _employees.add(employee);
    }
    _employees.sort((a, b) => a.name.compareTo(b.name));
  }

  void remove(int employeeUid) {
    _employees.removeWhere((e) => e.uid == employeeUid);
  }
}

// BLoC
class EmployeesBloc extends Bloc<EmployeesEvent, EmployeesState> {
  final EmployeeRepository _employeeRepository;
  final _EmployeesController _controller = _EmployeesController();
  EmployeesBloc(this._employeeRepository) : super(const EmployeesInitial()) {
    on<LoadEmployeesEvent>(_onLoadEmployees);
    on<CreateEmployeeEvent>(_onCreateEmployee);
    on<UpdateEmployeeEvent>(_onUpdateEmployee);
    on<ToggleEmployeeStatusEvent>(_onToggleStatus);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
    on<FindEmployeeByQueryEvent>(_onFindEmployee);
    on<LoadEmployeeSummaryEvent>(_onLoadSummary);
    on<LoadFingerprintsEvent>(_onLoadFingerprints);
    on<AddFingerprintEvent>(_onAddFingerprint);
    on<DeleteFingerprintEvent>(_onDeleteFingerprint);
    on<SearchByFingerprintEvent>(_onSearchByFingerprint);
    on<ImportCsvEvent>(_onImportCsv);
  }

  Future<void> _onLoadEmployees(
    LoadEmployeesEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.get();
    result.fold((failure) => emit(EmployeesError(failure.message)), (
      employees,
    ) {
      _controller.loadAll(
        employees.cast()..sort((a, b) => a.name.compareTo(b.name)),
      );
      emit(EmployeesLoaded(_controller.employees));
    });
  }

  Future<void> _onCreateEmployee(
    CreateEmployeeEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.create(event.employee);
    result.fold((failure) => emit(EmployeesError(failure.message)), (entity) {
      final model = EmployeeModel.fromEntity(entity);
      _controller.put(model);
      emit(EmployeesLoaded(_controller.employees));
    });
  }

  Future<void> _onUpdateEmployee(
    UpdateEmployeeEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.update(event.employee);
    result.fold((failure) => emit(EmployeesError(failure.message)), (_) {
      final model = EmployeeModel.fromEntity(event.employee);
      _controller.put(model);
      emit(EmployeesLoaded(_controller.employees));
    });
  }

  Future<void> _onToggleStatus(
    ToggleEmployeeStatusEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    final result = await _employeeRepository.toggleStatus(
      event.employeeId,
      event.isActive,
    );
    result.fold((failure) => emit(EmployeesError(failure.message)), (_) {
      final current = _controller.employees
          .where((e) => e.uid == event.employeeId)
          .firstOrNull;
      if (current != null) {
        _controller.put(current.copyWith(isActive: event.isActive));
      }
      emit(EmployeesLoaded(_controller.employees));
    });
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.delete(event.employeeId);
    result.fold((failure) => emit(EmployeesError(failure.message)), (_) {
      _controller.remove(event.employeeId);
      emit(EmployeesLoaded(_controller.employees));
    });
  }

  Future<void> _onFindEmployee(
    FindEmployeeByQueryEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.getEmployeeByQuery(
      employeeId: event.employeeId,
      cardNo: event.cardNo,
    );
    result.fold(
      (failure) => emit(EmployeesError(failure.message)),
      (employee) => emit(EmployeeQueryResult(employee)),
    );
  }

  Future<void> _onLoadSummary(
    LoadEmployeeSummaryEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.getEmployeeSummary(
      event.employeeUid,
    );
    result.fold(
      (failure) => emit(EmployeesError(failure.message)),
      (summary) => emit(EmployeeSummaryLoaded(summary)),
    );
  }

  Future<void> _onLoadFingerprints(
    LoadFingerprintsEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.getFingerprints(event.employeeUid);
    result.fold(
      (failure) => emit(EmployeesError(failure.message)),
      (fps) => emit(FingerprintsLoaded(fps)),
    );
  }

  Future<void> _onAddFingerprint(
    AddFingerprintEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    final result = await _employeeRepository.addFingerprint(event.entity);
    result.fold((failure) => emit(EmployeesError(failure.message)), (_) {
      emit(const EmployeesOperationSuccess('تمت إضافة البصمة بنجاح'));
      add(LoadFingerprintsEvent(employeeUid: event.entity.employeeId));
    });
  }

  Future<void> _onDeleteFingerprint(
    DeleteFingerprintEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    final result = await _employeeRepository.deleteFingerprint(
      event.employeeUid,
      event.fingerprintId,
    );
    result.fold((failure) => emit(EmployeesError(failure.message)), (_) {
      emit(const EmployeesOperationSuccess('تم حذف البصمة بنجاح'));
      add(LoadFingerprintsEvent(employeeUid: event.employeeUid));
    });
  }

  Future<void> _onSearchByFingerprint(
    SearchByFingerprintEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.searchEmployeeByFingerprint(
      event.biometric,
    );
    result.fold(
      (failure) => emit(EmployeesError(failure.message)),
      (searchResult) => emit(FingerprintSearchResultState(searchResult)),
    );
  }

  Future<void> _onImportCsv(
    ImportCsvEvent event,
    Emitter<EmployeesState> emit,
  ) async {
    emit(const EmployeesLoading());
    final result = await _employeeRepository.importEmployeesFromCsv(
      event.csvContent,
    );
    result.fold((failure) => emit(EmployeesError(failure.message)), (data) {
      emit(
        CsvImportResultState(
          created: data['created'] as int? ?? 0,
          updated: data['updated'] as int? ?? 0,
          errors: (data['errors'] as List<dynamic>?)?.cast<String>() ?? [],
        ),
      );
      add(const LoadEmployeesEvent());
    });
  }
}
