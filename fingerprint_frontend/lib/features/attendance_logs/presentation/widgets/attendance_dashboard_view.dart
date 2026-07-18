import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';
import 'attendance_logs_tab.dart';

class AttendanceLogDashboardView extends StatefulWidget {
  const AttendanceLogDashboardView({super.key});

  @override
  State<AttendanceLogDashboardView> createState() =>
      _AttendanceLogDashboardViewState();
}

class _AttendanceLogDashboardViewState extends State<AttendanceLogDashboardView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    context.read<EmployeesBloc>().add(const LoadEmployeesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.attendance),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            // Tab(text: 'الحضور اليومي', icon: Icon(Icons.today)),
            Tab(
              text: AppLocalizations.of(context)!.rawFingerprints,
              icon: Icon(Icons.fingerprint),
            ),
            // Tab(text: 'تقارير الانضباط', icon: Icon(Icons.analytics)),
            // Tab(text: 'تقرير البصمات', icon: Icon(Icons.receipt_long)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: NeverScrollableScrollPhysics(),
        children: const [
          // DailyRecordsTab(),
          AttendanceLogsTab(),
          // RawFingerprintReportTab(),
          // DisciplineReportsTab(),
        ],
      ),
    );
  }
}
