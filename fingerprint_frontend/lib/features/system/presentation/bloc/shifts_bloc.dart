import 'package:flutter_bloc/flutter_bloc.dart';
import 'shifts_event.dart';
import 'shifts_state.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';

class ShiftsBloc extends Bloc<ShiftsEvent, ShiftsState> {
  final ShiftsRepository _shiftsRepository;

  ShiftsBloc(this._shiftsRepository) : super(const ShiftsInitial()) {
    on<LoadShiftsEvent>(_onLoadShifts);
    on<CreateShiftEvent>(_onCreateShift);
    on<UpdateShiftEvent>(_onUpdateShift);
    on<DeleteShiftEvent>(_onDeleteShift);
  }

  Future<void> _onLoadShifts(
    LoadShiftsEvent event,
    Emitter<ShiftsState> emit,
  ) async {
    emit(const ShiftsLoading());
    final result = await _shiftsRepository.get();
    result.fold(
      (failure) => emit(ShiftsError(failure.message)),
      (shifts) => emit(ShiftsLoaded(shifts.cast())),
    );
  }

  Future<void> _onCreateShift(
    CreateShiftEvent event,
    Emitter<ShiftsState> emit,
  ) async {
    emit(const ShiftsLoading());
    final result = await _shiftsRepository.create(event.shift);
    result.fold(
      (failure) => emit(ShiftsError(failure.message)),
      (_) {
        emit(const ShiftsOperationSuccess('تم إنشاء الوردية بنجاح'));
        add(const LoadShiftsEvent());
      },
    );
  }

  Future<void> _onUpdateShift(
    UpdateShiftEvent event,
    Emitter<ShiftsState> emit,
  ) async {
    emit(const ShiftsLoading());
    final result = await _shiftsRepository.update(event.shift);
    result.fold(
      (failure) => emit(ShiftsError(failure.message)),
      (_) {
        emit(const ShiftsOperationSuccess('تم تحديث الوردية بنجاح'));
        add(const LoadShiftsEvent());
      },
    );
  }

  Future<void> _onDeleteShift(
    DeleteShiftEvent event,
    Emitter<ShiftsState> emit,
  ) async {
    emit(const ShiftsLoading());
    final result = await _shiftsRepository.delete(event.id);
    result.fold(
      (failure) => emit(ShiftsError(failure.message)),
      (_) {
        emit(const ShiftsOperationSuccess('تم حذف الوردية بنجاح'));
        add(const LoadShiftsEvent());
      },
    );
  }
}
