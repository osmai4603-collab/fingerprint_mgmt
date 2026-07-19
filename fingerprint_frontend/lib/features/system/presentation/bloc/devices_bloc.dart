import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'devices_event.dart';
import 'devices_state.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  final BiometricDevicesRepository _biometricDevicesRepository;

  DevicesBloc(this._biometricDevicesRepository)
    : super(const DevicesInitial()) {
    on<LoadDevicesEvent>(_onLoadDevices);
    on<CreateDeviceEvent>(_onCreateDevice);
    on<UpdateDeviceEvent>(_onUpdateDevice);
    on<DeleteDeviceEvent>(_onDeleteDevice);
    on<UpdateDeviceStatusEvent>(_onUpdateDeviceStatus);
  }

  Future<void> _onLoadDevices(
    LoadDevicesEvent event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    final result = await _biometricDevicesRepository.get();
    result.fold(
      (failure) => emit(DevicesError(failure.message)),
      (devices) => emit(DevicesLoaded(devices.cast())),
    );
  }

  Future<void> _onCreateDevice(
    CreateDeviceEvent event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    final result = await _biometricDevicesRepository.create(event.device);
    result.fold((failure) => emit(DevicesError(failure.message)), (device) {
      emit(const DevicesOperationSuccess('تم إضافة الجهاز بنجاح'));
      add(const LoadDevicesEvent());
    });
  }

  Future<void> _onUpdateDevice(
    UpdateDeviceEvent event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    final result = await _biometricDevicesRepository.update(event.device);
    result.fold((failure) => emit(DevicesError(failure.message)), (_) {
      emit(const DevicesOperationSuccess('تم تحديث الجهاز بنجاح'));
      add(const LoadDevicesEvent());
    });
  }

  Future<void> _onDeleteDevice(
    DeleteDeviceEvent event,
    Emitter<DevicesState> emit,
  ) async {
    emit(const DevicesLoading());
    final result = await _biometricDevicesRepository.delete(event.id);
    result.fold((failure) => emit(DevicesError(failure.message)), (_) {
      emit(const DevicesOperationSuccess('تم حذف الجهاز بنجاح'));
      add(const LoadDevicesEvent());
    });
  }

  Future<void> _onUpdateDeviceStatus(
    UpdateDeviceStatusEvent event,
    Emitter<DevicesState> emit,
  ) async {
    final result = await _biometricDevicesRepository.pingDevice(event.id);
    result.fold((failure) => emit(DevicesError(failure.message)), (_) {
      emit(const DevicesOperationSuccess('تم تحديث حالة الجهاز'));
      add(const LoadDevicesEvent());
    });
  }
}
