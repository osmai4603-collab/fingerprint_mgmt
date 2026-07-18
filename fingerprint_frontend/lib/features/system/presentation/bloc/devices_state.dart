import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();
}

class DevicesInitial extends DevicesState {
  const DevicesInitial();
  @override
  List<Object?> get props => [];
}

class DevicesLoading extends DevicesState {
  const DevicesLoading();
  @override
  List<Object?> get props => [];
}

class DevicesLoaded extends DevicesState {
  final List<BiometricDeviceModel> devices;
  const DevicesLoaded(this.devices);
  @override
  List<Object?> get props => [devices];
}

class DevicesOperationSuccess extends DevicesState {
  final String message;
  const DevicesOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class DevicesError extends DevicesState {
  final String message;
  const DevicesError(this.message);
  @override
  List<Object?> get props => [message];
}
