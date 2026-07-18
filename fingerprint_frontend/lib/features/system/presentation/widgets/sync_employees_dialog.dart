import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/shifts_repository.dart';
import 'package:fingerprint_frontend/features/employees/presentation/widgets/employee_form_dialog.dart';
import 'package:get_it/get_it.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class SyncEmployeesDialog extends StatefulWidget {
  final List<DeviceUser> deviceUsers;

  const SyncEmployeesDialog({super.key, required this.deviceUsers});

  static Future<void> show(BuildContext context, List<DeviceUser> deviceUsers) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SyncEmployeesDialog(deviceUsers: deviceUsers),
      ),
    );
  }

  @override
  State<SyncEmployeesDialog> createState() => _SyncEmployeesDialogState();
}

class _SyncItem {
  final DeviceUser deviceUser;
  EmployeeModel? existingEmployee;
  bool isSelected;
  int? selectedShiftId;
  String editedName;

  _SyncItem({
    required this.deviceUser,
    this.existingEmployee,
    required this.isSelected,
    this.selectedShiftId,
    String? editedName,
  }) : editedName = editedName ?? deviceUser.name;
}

class _SyncEmployeesDialogState extends State<SyncEmployeesDialog> {
  final _employeeRepo = GetIt.instance<EmployeeRepository>();
  final _shiftsRepo = GetIt.instance<ShiftsRepository>();

  List<_SyncItem> _items = [];
  List<ShiftModel> _shifts = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final shiftResult = await _shiftsRepo.get();
    List<ShiftModel> shifts = [];
    shiftResult.fold((_) {}, (list) {
      shifts = list.cast<ShiftModel>();
      if (mounted) setState(() => _shifts = shifts);
    });

    final singleShiftId = shifts.length == 1 ? shifts.first.id : null;

    final checks = widget.deviceUsers.map(
      (u) => _employeeRepo.getEmployeeByQuery(employeeId: u.userId),
    );
    final checkResults = await Future.wait(checks);

    final items = <_SyncItem>[];
    for (int i = 0; i < widget.deviceUsers.length; i++) {
      EmployeeModel? existing;
      checkResults[i].fold((_) {}, (emp) => existing = emp);
      items.add(
        _SyncItem(
          deviceUser: widget.deviceUsers[i],
          existingEmployee: existing,
          isSelected: true,
          selectedShiftId: existing?.defaultShiftId ?? singleShiftId,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final styles = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 1000,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colors),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.all(60),
                child: Center(
                  child: ShimmerLoading.table(rows: 20, columns: 5),
                ),
              )
            else ...[
              _buildTableHeader(colors, styles),
              Flexible(child: _buildTableBody(colors, styles)),
              _buildBottomBar(styles),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مزامنة الموظفين مع قاعدة البيانات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'عدد الموظفين في الجهاز: ${widget.deviceUsers.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: _isSyncing ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ColorScheme colors, TextTheme styles) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withAlpha(100),
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Text(
              'رقم الموظف',
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الاسم',
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الوردية',
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'الحالة',
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'إجراءات',
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(ColorScheme colors, TextTheme styles) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildRow(_items[index], index, colors, styles);
      },
    );
  }

  Widget _buildRow(
    _SyncItem item,
    int index,
    ColorScheme colors,
    TextTheme styles,
  ) {
    final isNew = item.existingEmployee == null;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withAlpha(50)),
        ),
        color: index.isEven
            ? null
            : colors.surfaceContainerHighest.withAlpha(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: _isSyncing
                ? null
                : (v) => setState(() => item.isSelected = v ?? true),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.deviceUser.userId,
              textAlign: TextAlign.center,
              style: styles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.editedName.isEmpty ? '---' : item.editedName,
              textAlign: TextAlign.center,
              style: styles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: item.selectedShiftId,
                  isExpanded: true,
                  isDense: true,
                  onChanged: _isSyncing
                      ? null
                      : (v) => setState(() => item.selectedShiftId = v),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('بدون وردية', style: styles.bodySmall),
                    ),
                    ..._shifts.map(
                      (s) => DropdownMenuItem(
                        value: s.id,
                        alignment: .centerStart,
                        child: Text(
                          "${s.name} ${formatTime(s.startTime)} ${formatTime(s.endTime)}",
                          style: styles.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNew
                      ? Theme.of(context).colorScheme.lateStatus.withAlpha(25)
                      : Theme.of(context).colorScheme.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isNew ? AppLocalizations.of(context)!.newLabel : AppLocalizations.of(context)!.existingLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isNew
                        ? Theme.of(context).colorScheme.lateStatus
                        : Theme.of(context).colorScheme.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: Icon(Icons.edit_outlined, size: 20),
                tooltip: AppLocalizations.of(context)!.editUser,
                onPressed: _isSyncing ? null : () => _editEmployee(item),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(TextTheme styles) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            AppLocalizations.of(context)!.selectedCountFormat(_items.where((i) => i.isSelected).length, _items.length),
            style: styles.bodyMedium,
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _isSyncing ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          SizedBox(width: 12),
          FilledButton.icon(
            onPressed: (_items.where((i) => i.isSelected).isEmpty || _isSyncing)
                ? null
                : _sync,
            icon: _isSyncing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Icon(Icons.sync, size: 20),
            label: Text(_isSyncing ? 'جارٍ المزامنة...' : 'مزامنة البيانات'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editEmployee(_SyncItem item) async {
    final isNew = item.existingEmployee == null;

    if (isNew) {
      await _showInlineEditDialog(item);
    } else {
      await showDialog(
        context: context,
        builder: (ctx) => EmployeeFormDialog(employee: item.existingEmployee),
      );
      final result = await _employeeRepo.getEmployeeByQuery(
        employeeId: item.deviceUser.userId,
      );
      result.fold((_) {}, (emp) {
        final idx = _items.indexOf(item);
        if (idx >= 0 && mounted) {
          setState(() {
            _items[idx].existingEmployee = emp;
            if (emp != null) {
              _items[idx].editedName = emp.name;
            }
          });
        }
      });
    }
  }

  Future<void> _showInlineEditDialog(_SyncItem item) async {
    final nameController = TextEditingController(text: item.deviceUser.name);
    final role = EmployeeRole.fromPrivilege(item.deviceUser.privilege);
    var selectedRole = role;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.editBeforeSync),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.name,
                    prefixIcon: Icon(Icons.person_2_rounded),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<EmployeeRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.role,
                    prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                  ),
                  items: EmployeeRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.displayName(null)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) selectedRole = v;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final idx = _items.indexOf(item);
      if (idx >= 0) {
        setState(() {
          _items[idx].editedName = nameController.text.trim();
        });
      }
    }
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);

    int created = 0;
    int updated = 0;
    int failed = 0;
    int skipped = 0;

    for (final item in _items) {
      if (!item.isSelected) {
        skipped++;
        continue;
      }

      final employeeID = item.deviceUser.userId;
      final name = item.editedName;
      final privilege = item.deviceUser.privilege;
      final cardNo = item.deviceUser.card == 0 ? null : item.deviceUser.card;

      if (item.existingEmployee == null) {
        final entity = EmployeeEntity(
          uid: 0,
          employeeID: employeeID,
          name: name,
          role: EmployeeRole.fromPrivilege(privilege),
          cardNo: cardNo,
          defaultShiftId: item.selectedShiftId,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final result = await _employeeRepo.create(entity);
        result.fold((_) => failed++, (_) => created++);
      } else {
        final updatedEntity = item.existingEmployee!.copyWith(
          name: name,
          cardNo: cardNo,
          defaultShiftId: item.selectedShiftId,
        );
        final result = await _employeeRepo.update(updatedEntity);
        result.fold((_) => failed++, (_) => updated++);
      }
    }

    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed > 0
              ? loc!.syncCompleteWithErrors(created, updated, skipped, failed)
              : loc!.syncCompleteSuccess(created, updated, skipped),
        ),
        backgroundColor: failed > 0 ? Theme.of(context).colorScheme.lateStatus : Theme.of(context).colorScheme.success,
      ),
    );

    setState(() => _isSyncing = false);
    Navigator.of(context).pop();
  }
}
