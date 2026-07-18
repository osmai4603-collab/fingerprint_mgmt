import 'dart:io';

import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/widgets/icon_button_widget.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:fingerprint_frontend/features/employees/presentation/widgets/employee_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/widgets/table_widget.dart';
import '../bloc/employees_bloc.dart';
import 'employee_profile_dialog.dart';
import 'fingerprints_mgmt_dialog.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class EmployeesDashboardView extends StatefulWidget {
  const EmployeesDashboardView({super.key});

  @override
  State<EmployeesDashboardView> createState() => _EmployeesDashboardViewState();
}

class _EmployeesDashboardViewState extends State<EmployeesDashboardView> {
  bool _showActiveOnly = true;
  String? _filterGroup;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeesBloc>().add(const LoadEmployeesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.employees),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            tooltip: localization.reload,
            onPressed: () =>
                context.read<EmployeesBloc>().add(const LoadEmployeesEvent()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocConsumer<EmployeesBloc, EmployeesState>(
              listener: (context, state) {
                if (state is EmployeesOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SelectableText(state.message),
                      backgroundColor: Theme.of(context).colorScheme.success,
                    ),
                  );
                }
                if (state is CsvImportResultState) {
                  final msg = state.errors.isNotEmpty
                      ? AppLocalizations.of(
                          context,
                        )!.employeeImportResultWithErrors(
                          state.created,
                          state.updated,
                          state.errors.length,
                        )
                      : AppLocalizations.of(
                          context,
                        )!.employeeImportResult(state.created, state.updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SelectableText(msg),
                      backgroundColor: Theme.of(context).colorScheme.success,
                    ),
                  );
                }
                if (state is EmployeesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: SelectableText(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is EmployeesLoading && state is! EmployeesLoaded) {
                  return ShimmerLoading.table(rows: 20, columns: 7);
                }
                final employees = state is EmployeesLoaded
                    ? state.employees
                    : <EmployeeModel>[];
                final filtered = _applyFilters(employees);
                if (filtered.isEmpty) {
                  return Center(child: Text(localization.noEmployees));
                }
                return _buildEmployeesTable(filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<EmployeeModel> _applyFilters(List<EmployeeModel> employees) {
    return employees.where((e) {
      if (_showActiveOnly && !e.isActive) return false;
      if (_filterGroup != null &&
          _filterGroup!.isNotEmpty &&
          e.groupId != _filterGroup) {
        return false;
      }
      final query = _searchController.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        final matchesId = e.employeeID.toLowerCase().contains(query);
        final matchesCard = e.cardNo?.toString().contains(query) ?? false;
        final matchesName = e.name.toLowerCase().contains(query);
        if (!matchesId && !matchesCard && !matchesName) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildFilterBar() {
    final localization = AppLocalizations.of(context)!;
    final styles = Theme.of(context).textTheme;
    final groups = context.read<EmployeesBloc>().state is EmployeesLoaded
        ? (context.read<EmployeesBloc>().state as EmployeesLoaded).employees
              .map((e) => e.groupId)
              .where((g) => g != null && g.isNotEmpty)
              .toSet()
              .toList()
        : <String?>[];

    return Container(
      height: 50.0,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localization.searchByNameOrCode,
                prefixIcon: Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: DropdownButtonFormField<String?>(
              style: styles.bodyMedium,
              initialValue: _filterGroup,
              decoration: InputDecoration(
                labelText: localization.group,
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(localization.all)),
                ...groups.map(
                  (g) => DropdownMenuItem(
                    value: g,
                    child: Text(g!, style: styles.bodyLarge),
                  ),
                ),
              ],
              // selectedItemBuilder: (_) {
              //   return groups.map((group) {
              //     return Text(group ?? '', style: styles.bodyMedium);
              //   }).toList();
              // },
              onChanged: (v) => setState(() => _filterGroup = v),
            ),
          ),
          SizedBox(width: 12),
          ChoiceChip(
            label: Text(
              _showActiveOnly ? localization.active : localization.all,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _showActiveOnly
                    ? Theme.of(context).colorScheme.onTertiaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: .bold,
              ),
            ),
            selected: _showActiveOnly,
            onSelected: (v) => setState(() => _showActiveOnly = v),
            selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
            labelStyle: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _importCsv,
            icon: Icon(Icons.upload_file, size: 18),
            label: Text(localization.importCSV),
          ),
          SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => _showEmployeeForm(context),
            icon: Icon(Icons.add, size: 18),
            label: Text(localization.addNewEmployee),
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      if (mounted) {
        context.read<EmployeesBloc>().add(ImportCsvEvent(csvContent: content));
      }
    }
  }

  final _columns = const {
    0: FixedTableWidgetColumnWidth(
      80,
      alignment: .centerStart,
      padding: .symmetric(horizontal: 8),
    ),
    1: FlexTableWidgetColumnWidth(
      1,
      alignment: .centerRight,
      padding: .symmetric(horizontal: 8),
    ),
    2: FlexTableWidgetColumnWidth(3, alignment: .centerStart),
    3: FlexTableWidgetColumnWidth(1, alignment: .center),
    4: FlexTableWidgetColumnWidth(1, alignment: .center),
    5: FlexTableWidgetColumnWidth(1, alignment: .center),
    6: FlexTableWidgetColumnWidth(3, alignment: .center),
  };

  Widget _buildEmployeesTable(List<EmployeeModel> employees) {
    final localization = AppLocalizations.of(context)!;
    final headers = [
      localization.tableNo,
      localization.code,
      localization.name,
      localization.role,
      localization.card,
      localization.status,
      localization.actions,
    ];

    return TableWidget<EmployeeModel>(
      columns: _columns,
      header: headers,
      items: employees,
      paintRowColorWhen: (employee, _) => !employee.isActive,
      rowColor: Theme.of(context).colorScheme.surfaceContainer,
      builder: (context, employee, index) {
        return [
          Text('${index + 1}', style: TextStyle(fontSize: 14)),
          Text(employee.employeeID, style: TextStyle(fontSize: 14)),
          Text(employee.name, style: TextStyle(fontSize: 14)),
          Text(employee.role.displayName(null), style: TextStyle(fontSize: 14)),
          Text(
            employee.cardNo?.toString() ?? '-',
            style: TextStyle(fontSize: 14),
          ),
          Icon(
            employee.isActive ? Icons.check_circle : Icons.cancel,
            color: employee.isActive
                ? Theme.of(context).colorScheme.success
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButtonWidget(
                tooltip: localization.profile,
                icon: Icons.person_rounded,

                onPressed: () => _showProfile(context, employee),
              ),
              IconButtonWidget(
                tooltip: localization.manageFingerprints,
                icon: Icons.fingerprint,

                onPressed: () => _showFingerprints(context, employee),
              ),
              IconButtonWidget(
                icon: Icons.edit,
                onPressed: () => _showEmployeeForm(context, employee: employee),
              ),
              IconButtonWidget(
                icon: employee.isActive
                    ? Icons.block
                    : Icons.check_circle_outline,

                onPressed: () => context.read<EmployeesBloc>().add(
                  ToggleEmployeeStatusEvent(
                    employeeId: employee.uid,
                    isActive: !employee.isActive,
                  ),
                ),
              ),
              IconButtonWidget(
                icon: Icons.delete,
                iconColor: Theme.of(context).colorScheme.error,

                onPressed: () => _confirmDelete(context, employee),
              ),
            ],
          ),
        ];
      },
    );
  }

  void _showProfile(BuildContext context, EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EmployeesBloc>(),
        child: EmployeeProfileDialog(employee: employee),
      ),
    );
  }

  void _showFingerprints(BuildContext context, EmployeeModel employee) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EmployeesBloc>(),
        child: FingerprintsMgmtDialog(employee: employee),
      ),
    );
  }

  void _showEmployeeForm(
    BuildContext context, {
    EmployeeModel? employee,
  }) async {
    final result = await showDialog<EmployeeEntity>(
      context: context,
      builder: (_) => EmployeeFormDialog(employee: employee),
    );
    if (result == null) return;
    if (context.mounted) {
      if (employee != null) {
        context.read<EmployeesBloc>().add(
          UpdateEmployeeEvent(employee: result),
        );
      } else {
        context.read<EmployeesBloc>().add(
          CreateEmployeeEvent(employee: result),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, EmployeeModel employee) async {
    final result =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => ConfirmDeleteDialog(
            title: AppLocalizations.of(context)!.confirmDelete,
            content: AppLocalizations.of(
              context,
            )!.confirmDeleteEmployee(employee.name),
          ),
        ) ??
        false;
    if (result && context.mounted) {
      context.read<EmployeesBloc>().add(
        DeleteEmployeeEvent(employeeId: employee.uid),
      );
    }
  }
}
