import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';

class LinkLogModal extends StatefulWidget {
  final int logId;
  const LinkLogModal({super.key, required this.logId});

  @override
  State<LinkLogModal> createState() => _LinkLogModalState();
}

class _LinkLogModalState extends State<LinkLogModal> {
  int? _selectedEmployeeId;

  @override
  void initState() {
    super.initState();
    context.read<EmployeesBloc>().add(const LoadEmployeesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.linkFingerprintToEmployee),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<EmployeesBloc, EmployeesState>(
              builder: (context, state) {
                if (state is EmployeesLoading) {
                  return Center(
                    heightFactor: 2,
                    child: ShimmerLoading.box(height: 56),
                  );
                }
                if (state is EmployeesLoaded) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedEmployeeId,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.selectEmployee,
                      border: OutlineInputBorder(),
                    ),
                    items: state.employees.map((emp) {
                      return DropdownMenuItem<int>(
                        value: emp.uid,
                        child: Text(AppLocalizations.of(context)!.employeeNameIdFormat(emp.name, emp.uid.toString())),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedEmployeeId = val);
                    },
                  );
                }
                return Text(AppLocalizations.of(context)!.errorFetchingEmployees);
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
                    LinkUnrecognizedLogEvent(
                      logId: widget.logId,
                      employeeId: _selectedEmployeeId!,
                    ),
                  );
                  Navigator.pop(context, true);
                },
          child: Text(AppLocalizations.of(context)!.link),
        ),
      ],
    );
  }
}
