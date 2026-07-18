import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class ShiftsState extends Equatable {
  const ShiftsState();
}

class ShiftsInitial extends ShiftsState {
  const ShiftsInitial();
  @override
  List<Object?> get props => [];
}

class ShiftsLoading extends ShiftsState {
  const ShiftsLoading();
  @override
  List<Object?> get props => [];
}

class ShiftsLoaded extends ShiftsState {
  final List<ShiftEntity> shifts;
  const ShiftsLoaded(this.shifts);
  @override
  List<Object?> get props => [shifts];
}

class ShiftsOperationSuccess extends ShiftsState {
  final String message;
  const ShiftsOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ShiftsError extends ShiftsState {
  final String message;
  const ShiftsError(this.message);
  @override
  List<Object?> get props => [message];
}
