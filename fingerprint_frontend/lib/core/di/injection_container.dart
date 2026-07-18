import 'package:fingerprint_frontend/core/repositories/api_impl/auth_repository_impl.dart';
import 'package:fingerprint_frontend/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/users_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/attendance_logs_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:fingerprint_frontend/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:fingerprint_frontend/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/auth_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/users_repository.dart';
import 'package:fingerprint_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fingerprint_frontend/features/auth/presentation/bloc/users_bloc.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/employee_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/features/employees/presentation/bloc/employees_bloc.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/shifts_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/biometric_devices_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/features/system/presentation/bloc/devices_bloc.dart';
import 'package:fingerprint_frontend/features/system/presentation/bloc/shifts_bloc.dart';
import 'package:fingerprint_frontend/core/repositories/api_impl/attendance_records_repository_impl.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_records_repository.dart';
import 'package:fingerprint_frontend/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../network/websocket_client.dart';
import '../services/backend_manager.dart';
import '../services/user_session.dart';
import '../device/biometric_device_controller.dart';
import '../shared/shared_core.dart';

final get_it = GetIt.instance;

Future<void> init() async {
  get_it.registerLazySingleton(() => Dio());
  get_it.registerLazySingleton(() => UserSession());
  get_it.registerLazySingleton(() => BackendManager());
  get_it.registerLazySingleton(() => ApiClient(get_it(), get_it()));
  get_it.registerLazySingleton(
    () => BiometricWebSocketClient(wsUrl: 'ws://localhost:8000/api/ws/devices'),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  get_it.registerLazySingleton(() => sharedPreferences);

  get_it.registerLazySingleton<SettingsBloc>(
    () => SettingsBloc(sharedPreferences: get_it()),
  );

  get_it.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<ShiftsRepository>(
    () => ShiftsRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<BiometricDevicesRepository>(
    () => BiometricDevicesRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<EmployeeRepository>(
    () => EmployeeRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<AttendanceLogsRepository>(
    () => AttendanceLogsRepositoryImpl(get_it()),
  );
  get_it.registerLazySingleton<AttendanceRecordsRepository>(
    () => AttendanceRecordsRepositoryImpl(get_it()),
  );

  get_it.registerFactory(() => AuthBloc(get_it()));
  get_it.registerFactory(() => UsersBloc(get_it()));
  get_it.registerFactory(() => ShiftsBloc(get_it()));
  get_it.registerFactory(() => DevicesBloc(get_it()));
  get_it.registerFactory(() => EmployeesBloc(get_it()));
  get_it.registerFactory(() => AttendanceBloc(get_it()));
  get_it.registerFactory(() => ReportsBloc(get_it()));
  get_it.registerFactory(() => DashboardBloc(
    get_it(),
    get_it(),
    get_it(),
    get_it(),
    get_it(),
  ));

  get_it.registerFactoryParam<
    BiometricDeviceController,
    BiometricDeviceEntity,
    void
  >(
    (device, _) => BiometricDeviceController(
      device: device,
      repository: get_it(),
      wsClient: get_it(),
    ),
  );
}
