import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';

class AttendanceLogFormDialog extends StatefulWidget {
  const AttendanceLogFormDialog({super.key});

  @override
  State<AttendanceLogFormDialog> createState() =>
      _AttendanceLogFormDialogState();
}

class _AttendanceLogFormDialogState extends State<AttendanceLogFormDialog> {
  int? _selectedEmployeeId;
  DateTime _punchTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<EmployeesBloc>().add(const LoadEmployeesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addManualFingerprint),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<EmployeesBloc, EmployeesState>(
              builder: (context, state) {
                if (state is EmployeesLoading) {
                  return ShimmerLoading.box(height: 56);
                }
                if (state is EmployeesLoaded) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedEmployeeId,
                    hint: Text(AppLocalizations.of(context)!.selectEmployeeData),

                    decoration: InputDecoration(
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow,
                      labelText: AppLocalizations.of(context)!.employee,
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: .bold),
                    items: state.employees.map((emp) {
                      return DropdownMenuItem<int>(
                        value: emp.uid,
                        child: Text(AppLocalizations.of(context)!.employeeNameIdFormat(emp.name, emp.employeeID.toString())),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedEmployeeId = val),
                  );
                }
                return Text(AppLocalizations.of(context)!.errorFetchingEmployees);
              },
            ),
            SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4),
              tileColor: Theme.of(context).colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(borderRadius: .circular(8)),
              title: Text(
                AppLocalizations.of(context)!.fingerprintTime,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: .bold),
              ),
              subtitle: Text(
                '${formatDateTime(_punchTime)} ${getDayName(_punchTime)}',
                textDirection: .ltr,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: .bold),
              ),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _punchTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null && mounted) {
                  final time = await showTimePicker(
                    // ignore: use_build_context_synchronously
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_punchTime),
                  );
                  if (time != null) {
                    setState(() {
                      _punchTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedEmployeeId == null
              ? null
              : () {
                  context.read<AttendanceBloc>().add(
                    AddManualPunchEvent(
                      employeeId: _selectedEmployeeId!,
                      punchTime: _punchTime,
                    ),
                  );
                  Navigator.pop(context, true);
                },
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
          child: Text(AppLocalizations.of(context)!.addNew),
        ),
      ],
    );
  }
}
