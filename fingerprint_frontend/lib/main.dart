import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/backend_manager.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/users_bloc.dart';
import 'features/system/presentation/bloc/shifts_bloc.dart';
import 'features/system/presentation/bloc/devices_bloc.dart';
import 'features/employees/presentation/bloc/employees_bloc.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(const FingerprintMgmtApp());
}

class FingerprintMgmtApp extends StatefulWidget {
  const FingerprintMgmtApp({super.key});

  @override
  State<FingerprintMgmtApp> createState() => _FingerprintMgmtAppState();
}

class _FingerprintMgmtAppState extends State<FingerprintMgmtApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      di.get_it<BackendManager>().shutdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.get_it<AuthBloc>()),
        BlocProvider.value(value: di.get_it<UsersBloc>()),
        BlocProvider.value(value: di.get_it<ShiftsBloc>()),
        BlocProvider.value(value: di.get_it<DevicesBloc>()),
        BlocProvider.value(value: di.get_it<EmployeesBloc>()),
        BlocProvider.value(value: di.get_it<AttendanceBloc>()),
        BlocProvider.value(value: di.get_it<ReportsBloc>()),
        BlocProvider.value(value: di.get_it<DashboardBloc>()),
        BlocProvider.value(value: di.get_it<SettingsBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            onGenerateTitle: (context) {
              return AppLocalizations.of(context)?.appTitle ?? 'Attendance System';
            },
            themeMode: settingsState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settingsState.locale,
            routerConfig: NavigationService.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
