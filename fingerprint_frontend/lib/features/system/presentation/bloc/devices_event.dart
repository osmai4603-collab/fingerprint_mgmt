import 'package:equatable/equatable.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

abstract class DevicesEvent extends Equatable {
  const DevicesEvent();
}

class LoadDevicesEvent extends DevicesEvent {
  const LoadDevicesEvent();
  @override
  List<Object?> get props => [];
}

class CreateDeviceEvent extends DevicesEvent {
  final BiometricDeviceEntity device;
  const CreateDeviceEvent({required this.device});
  @override
  List<Object?> get props => [device];
}

class UpdateDeviceEvent extends DevicesEvent {
  final BiometricDeviceEntity device;
  const UpdateDeviceEvent(this.device);
  @override
  List<Object?> get props => [device];
}

class DeleteDeviceEvent extends DevicesEvent {
  final int id;
  const DeleteDeviceEvent({required this.id});
  @override
  List<Object?> get props => [id];
}

class UpdateDeviceStatusEvent extends DevicesEvent {
  final int id;
  final bool isOnline;
  const UpdateDeviceStatusEvent({required this.id, required this.isOnline});
  @override
  List<Object?> get props => [id, isOnline];
}
