import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import '../bloc/employees_bloc.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class EmployeeProfileDialog extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeProfileDialog({super.key, required this.employee});

  @override
  State<EmployeeProfileDialog> createState() => _EmployeeProfileDialogState();
}

class _EmployeeProfileDialogState extends State<EmployeeProfileDialog> {
  @override
  void initState() {
    super.initState();
    context.read<EmployeesBloc>().add(
      LoadEmployeeSummaryEvent(employeeUid: widget.employee.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: BlocBuilder<EmployeesBloc, EmployeesState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildInfoRow(
                    Icons.badge,
                    AppLocalizations.of(context)!.code,
                    widget.employee.employeeID,
                  ),
                  _buildInfoRow(Icons.person, AppLocalizations.of(context)!.name, widget.employee.name),
                  _buildInfoRow(Icons.work, AppLocalizations.of(context)!.role, widget.employee.role.name),
                  _buildInfoRow(
                    Icons.credit_card,
                    AppLocalizations.of(context)!.card,
                    widget.employee.cardNo?.toString() ?? '-',
                  ),
                  _buildInfoRow(
                    Icons.toggle_on,
                    AppLocalizations.of(context)!.status,
                    widget.employee.isActive ? AppLocalizations.of(context)!.active : AppLocalizations.of(context)!.inactive,
                  ),
                  Divider(height: 28),
                  if (state is EmployeeSummaryLoaded)
                    _buildSummary(state.summary),
                  if (state is EmployeesLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: ShimmerLoading.cardGrid(),
                    ),
                  SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              widget.employee.name.isNotEmpty ? widget.employee.name[0] : '?',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employee.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.employee.role.name,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(
            widget.employee.isActive ? Icons.check_circle : Icons.cancel,
            color: widget.employee.isActive
                ? Theme.of(context).colorScheme.success
                : Theme.of(context).colorScheme.error,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(EmployeeSummaryModel summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.statsSummary,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              Icons.access_time,
              AppLocalizations.of(context)!.workHours,
              '${summary.totalWorkingHours.toStringAsFixed(1)} س',
              Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8),
            _buildStatCard(
              Icons.schedule,
              AppLocalizations.of(context)!.lateTime,
              '${summary.totalLateMins} د',
              Theme.of(context).colorScheme.lateStatus,
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(
              Icons.timer,
              AppLocalizations.of(context)!.overtime,
              '${summary.totalOvertimeMins} د',
              Theme.of(context).colorScheme.success,
            ),
            SizedBox(width: 8),
            _buildStatCard(
              Icons.fingerprint,
              AppLocalizations.of(context)!.fingerprints,
              '${summary.fingerprintCount}',
              Theme.of(context).colorScheme.secondary,
            ),
          ],
        ),
        if (summary.shiftName != null) ...[
          SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, AppLocalizations.of(context)!.shifts, summary.shiftName!),
        ],
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
