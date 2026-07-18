import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class ShiftsEvent extends Equatable {
  const ShiftsEvent();
}

class LoadShiftsEvent extends ShiftsEvent {
  const LoadShiftsEvent();
  @override
  List<Object?> get props => [];
}

class CreateShiftEvent extends ShiftsEvent {
  final ShiftEntity shift;
  const CreateShiftEvent({required this.shift});
  @override
  List<Object?> get props => [shift];
}

class UpdateShiftEvent extends ShiftsEvent {
  final ShiftEntity shift;
  const UpdateShiftEvent({required this.shift});
  @override
  List<Object?> get props => [shift];
}

class DeleteShiftEvent extends ShiftsEvent {
  final int id;
  const DeleteShiftEvent({required this.id});
  @override
  List<Object?> get props => [id];
}
