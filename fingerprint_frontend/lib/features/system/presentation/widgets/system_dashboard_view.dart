import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/shifts_bloc.dart';
import '../bloc/devices_bloc.dart';
import '../pages/system_dashboard_page.dart';

class SystemDashboardView extends StatelessWidget {
  const SystemDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<ShiftsBloc>()),
        BlocProvider.value(value: context.read<DevicesBloc>()),
      ],
      child: const SystemDashboardPage(),
    );
  }
}
