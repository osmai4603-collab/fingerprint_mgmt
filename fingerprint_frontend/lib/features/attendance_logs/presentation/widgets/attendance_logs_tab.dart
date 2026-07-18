import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/icon_button_widget.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../../../../core/widgets/table_widget.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';
import 'attendance_log_form_dialog.dart';
import 'link_log_modal.dart';

class AttendanceLogsTab extends StatefulWidget {
  const AttendanceLogsTab({super.key});

  @override
  State<AttendanceLogsTab> createState() => _AttendanceLogsTabState();
}

class _AttendanceLogsTabState extends State<AttendanceLogsTab> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedEmployeeId;
  bool _unrecognizedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    context.read<AttendanceBloc>().add(
      LoadRawLogsEvent(
        fromDate: _fromDate,
        toDate: _toDate,
        employeeId: _selectedEmployeeId,
        unrecognizedOnly: _unrecognizedOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _fromDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _fromDate = date);
                    _loadLogs();
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text(
                  '${AppLocalizations.of(context)!.fromDate}: ${_fromDate == null ? AppLocalizations.of(context)!.dash : formatDate(_fromDate!)}',
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _toDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _toDate = date);
                    _loadLogs();
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text(
                  '${AppLocalizations.of(context)!.toDate}: ${_toDate == null ? AppLocalizations.of(context)!.dash : formatDate(_toDate!)}',
                ),
              ),
              if (_fromDate != null || _toDate != null) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _fromDate = null;
                      _toDate = null;
                    });
                    _loadLogs();
                  },
                  tooltip: AppLocalizations.of(context)!.clearDateFilter,
                ),
              ],
              SizedBox(width: 8),
              BlocBuilder<EmployeesBloc, EmployeesState>(
                builder: (context, state) {
                  if (state is EmployeesLoaded) {
                    return SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedEmployeeId,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.employee,
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              AppLocalizations.of(context)!.allEmployees,
                            ),
                          ),
                          ...state.employees.map(
                            (emp) => DropdownMenuItem<int?>(
                              value: emp.uid,
                              child: Text(emp.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() => _selectedEmployeeId = val);
                          _loadLogs();
                        },
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
              const Spacer(),
              Row(
                children: [
                  Text(AppLocalizations.of(context)!.unknownOnly),
                  Switch(
                    value: _unrecognizedOnly,
                    onChanged: (val) {
                      setState(() => _unrecognizedOnly = val);
                      _loadLogs();
                    },
                  ),
                ],
              ),
              SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AttendanceLogFormDialog(),
                  ).then((value) {
                    if (value == true) _loadLogs();
                  });
                },
                icon: Icon(Icons.add),
                label: Text(AppLocalizations.of(context)!.addManualAttendance),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<AttendanceBloc, AttendanceState>(
            listener: (context, state) {
              if (state is AttendanceOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: SelectableText(state.message)),
                );
                _loadLogs();
              } else if (state is AttendanceError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: SelectableText(
                      state.message,
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            buildWhen: (previous, current) =>
                current is AttendanceLoading ||
                current is AttendanceRawLogsLoaded ||
                current is AttendanceError,
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return Center(
                  child: ShimmerLoading.table(rows: 50, columns: 5),
                );
              }
              if (state is AttendanceRawLogsLoaded) {
                if (state.logs.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.noRawFingerprints,
                    ),
                  );
                }
                return _buildLogsTable(state.logs);
              }
              return Center(child: Text(AppLocalizations.of(context)!.dash));
            },
          ),
        ),
      ],
    );
  }

  final _columns = const {
    0: FixedTableWidgetColumnWidth(80, alignment: .centerRight),
    1: FlexTableWidgetColumnWidth(2, alignment: .centerStart),
    2: FlexTableWidgetColumnWidth(2, alignment: .center),
    3: FixedTableWidgetColumnWidth(250, alignment: .center),
    4: FixedTableWidgetColumnWidth(100, alignment: .center),
  };

  List<String> get _headers => [
    AppLocalizations.of(context)!.tableNo,
    AppLocalizations.of(context)!.employee,
    AppLocalizations.of(context)!.dateTime,
    AppLocalizations.of(context)!.device,
    AppLocalizations.of(context)!.action,
  ];

  Widget _buildLogsTable(List<AttendanceLogModel> logs) {
    return TableWidget<AttendanceLogModel>(
      columns: _columns,
      header: _headers,
      items: logs,
      minWidth: 1000,
      builder: (context, log, index) {
        final empName =
            log.employee?.name ??
            (log.employeeId != null
                ? 'ID: ${log.employeeId}'
                : AppLocalizations.of(
                    context,
                  )!.unknownWithId(int.tryParse(log.unrecognizedBiometric ?? '') ?? 0));
        return [
          Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 14,
              color: log.employeeId == null
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ),
          Text(
            empName,
            style: TextStyle(
              fontSize: 14,
              color: log.employeeId == null
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: .spaceAround,
            children: [
              Text(
                getDayName(log.punchTime),
                textDirection: .ltr,
                style: TextStyle(fontSize: 14),
              ),
              Text(
                formatDate(log.punchTime),
                textDirection: .ltr,
                style: TextStyle(fontSize: 14),
              ),
              Text(
                formatTime(log.punchTime),
                textDirection: .ltr,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Text(
            log.deviceId?.toString() ?? '----',
            style: TextStyle(fontSize: 14),
          ),
          log.employeeId == null
              ? ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => LinkLogModal(logId: log.id),
                    ).then((value) {
                      if (value == true) _loadLogs();
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.linkToEmployee),
                )
              : Row(
                  mainAxisAlignment: .center,
                  children: [
                    IconButtonWidget(
                      icon: Icons.remove_circle_outline_rounded,
                      onPressed: () {},
                    ),
                  ],
                ),
        ];
      },
    );
  }
}
