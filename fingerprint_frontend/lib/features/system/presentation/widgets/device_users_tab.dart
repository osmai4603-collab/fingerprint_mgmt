import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/features/employees/presentation/widgets/employee_form_dialog.dart';
import 'sync_employees_dialog.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DeviceUsersTab extends StatefulWidget {
  final BiometricDeviceModel device;
  final BiometricDevicesRepository biometricDevicesRepository;
  final bool isConnected;
  final void Function(String message, {Color? color}) onShowSnack;

  const DeviceUsersTab({
    super.key,
    required this.device,
    required this.biometricDevicesRepository,
    required this.isConnected,
    required this.onShowSnack,
  });

  @override
  State<DeviceUsersTab> createState() => DeviceUsersTabState();
}

class DeviceUsersTabState extends State<DeviceUsersTab> {
  List<DeviceUser> _users = [];
  bool _isFetchingUsers = false;

  Future<void> fetchUsers() => _fetchUsers();

  Future<void> _fetchUsers() async {
    setState(() => _isFetchingUsers = true);
    try {
      final result = await widget.biometricDevicesRepository.getDeviceUsers(
        widget.device.id,
      );
      result.fold(
        (failure) =>
            widget.onShowSnack(failure.message, color: Theme.of(context).colorScheme.error),
        (users) {
          if (mounted) setState(() => _users = users);
        },
      );
    } finally {
      if (mounted) setState(() => _isFetchingUsers = false);
    }
  }

  Future<void> _removeUser(DeviceUser user) async {
    final result = await widget.biometricDevicesRepository.deleteDeviceUser(
      widget.device.id,
      user.uid ?? 0,
      user.userId,
    );
    result.fold(
      (failure) => widget.onShowSnack(failure.message, color: Theme.of(context).colorScheme.error),
      (_) {
        widget.onShowSnack('تم حذف الموظف بنجاح');
        _fetchUsers();
      },
    );
  }

  void _confirmRemoveUser(DeviceUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDeleteDialog(
        title: 'تأكيد الحذف',
        content: 'هل أنت متأكد من حذف الموظف "${user.name}"؟',
        confirmText: 'حذف',
      ),
    );
    if (confirmed == true) {
      _removeUser(user);
    }
  }

  void _showAddUserDialog() async {
    final employee = await EmployeeFormDialog.show(context);
    if (employee == null) return;
    _syncEmployeeToDevice(employee);
  }

  Future<void> _syncEmployeeToDevice(EmployeeModel employee) async {
    final deviceUser = DeviceUser(
      uid: employee.uid,
      userId: employee.employeeID,
      name: employee.name,
      password: employee.password ?? '',
      card: employee.cardNo ?? 0,
      privilege: employee.role.index,
    );
    final result = await widget.biometricDevicesRepository.setDeviceUser(
      widget.device.id,
      deviceUser,
    );
    result.fold(
      (failure) => widget.onShowSnack(failure.message, color: Theme.of(context).colorScheme.error),
      (_) {
        widget.onShowSnack('تم إضافة الموظف بنجاح');
        _fetchUsers();
      },
    );
  }

  Future<void> _showSyncEmployeesDialog() async {
    if (_users.isEmpty) {
      widget.onShowSnack(
        'لا يوجد موظفين في الجهاز للمزامنة',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    if (!widget.isConnected) {
      widget.onShowSnack(
        'الرجاء الاتصال بالجهاز أولاً',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    await SyncEmployeesDialog.show(context, _users);
    _fetchUsers();
  }

  void _showUserDetails(DeviceUser user) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppLocalizations.of(context)!.employeeDetails(user.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(AppLocalizations.of(context)!.internalId, '${user.uid ?? "---"}'),
              _buildDetailRow(AppLocalizations.of(context)!.employeeCodeLabel, user.userId),
              _buildDetailRow(AppLocalizations.of(context)!.name, user.name),
              _buildDetailRow(AppLocalizations.of(context)!.role, _privilegeLabel(user.privilege)),
              _buildDetailRow(AppLocalizations.of(context)!.password, user.password),
              _buildDetailRow(AppLocalizations.of(context)!.cardNumber, '${user.card}'),
              _buildDetailRow(AppLocalizations.of(context)!.group, user.groupId),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(context)!.close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _privilegeLabel(int privilege) {
    final loc = AppLocalizations.of(context);
    return switch (privilege) {
      14 => loc!.privilegeManager,
      6 => loc!.privilegeSupervisor,
      2 => loc!.privilegeEnroller,
      _ => loc!.privilegeEmployee,
    };
  }

  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    final bodySmall = styles.bodySmall!;

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionHeader(),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.knownEmployees,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_users.isNotEmpty) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_users.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (widget.isConnected) ...[
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(),
                  icon: Icon(Icons.person_add, size: 18),
                  label: Text(AppLocalizations.of(context)!.addEmployee),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(width: 8),
              ],
              if (widget.isConnected && _users.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () => _showSyncEmployeesDialog(),
                  icon: Icon(Icons.sync, size: 18),
                  label: Text(AppLocalizations.of(context)!.sync),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.success,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
                SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: _isFetchingUsers ? null : _fetchUsers,
                icon: _isFetchingUsers
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.download),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: _users.isEmpty
                ? Center(
                    child: Text(
                      _isFetchingUsers ? AppLocalizations.of(context)!.loading : AppLocalizations.of(context)!.noEmployees,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : TableWidget<DeviceUser>(
                    header: [
                      AppLocalizations.of(context)!.internalId,
                      AppLocalizations.of(context)!.employeeCodeLabel,
                      AppLocalizations.of(context)!.name,
                      AppLocalizations.of(context)!.role,
                      AppLocalizations.of(context)!.cardNumber,
                      AppLocalizations.of(context)!.group,
                      AppLocalizations.of(context)!.delete,
                    ],
                    columns: const {
                      0: FixedTableWidgetColumnWidth(
                        80,
                        alignment: .centerRight,
                      ),
                      1: FixedTableWidgetColumnWidth(
                        120,
                        alignment: .centerRight,
                      ),
                      2: FlexTableWidgetColumnWidth(1, alignment: .centerStart),
                      3: FixedTableWidgetColumnWidth(100, alignment: .center),
                      4: FixedTableWidgetColumnWidth(
                        120,
                        alignment: .centerRight,
                      ),
                      5: FixedTableWidgetColumnWidth(120, alignment: .center),
                      6: FixedTableWidgetColumnWidth(60, alignment: .center),
                    },
                    items: _users,
                    onTapRow: (user) => _showUserDetails(user),
                    builder: (context, user, index) {
                      return [
                        Text('${user.uid ?? '---'}', style: bodySmall),
                        Text(user.userId),
                        Text(
                          user.name.isEmpty ? '---' : user.name,
                          style: bodySmall,
                        ),
                        Text(_privilegeLabel(user.privilege), style: bodySmall),
                        Text(
                          user.card == 0 ? '---' : '${user.card}',
                          style: bodySmall,
                        ),
                        Text(
                          user.groupId.isEmpty ? '---' : user.groupId,
                          style: bodySmall,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          tooltip: AppLocalizations.of(context)!.delete,
                          onPressed: () => _confirmRemoveUser(user),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ];
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionHeader() {
    final isConnected = widget.isConnected;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isConnected
            ? Theme.of(context).colorScheme.success.withAlpha(25)
            : Theme.of(context).colorScheme.error.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              key: ValueKey(isConnected),
              color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
            ),
            child: Text(isConnected ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnected),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
