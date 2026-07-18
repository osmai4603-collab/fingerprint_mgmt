import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DeviceTemplatesTab extends StatefulWidget {
  final BiometricDeviceModel device;
  final BiometricDevicesRepository biometricDevicesRepository;
  final bool isConnected;
  final void Function(String message, {Color? color}) onShowSnack;

  const DeviceTemplatesTab({
    super.key,
    required this.device,
    required this.biometricDevicesRepository,
    required this.isConnected,
    required this.onShowSnack,
  });

  @override
  State<DeviceTemplatesTab> createState() => DeviceTemplatesTabState();
}

class DeviceTemplatesTabState extends State<DeviceTemplatesTab> {
  List<DeviceFingerprint> _templates = [];
  bool _isFetchingTemplates = false;

  Future<void> fetchTemplates() => _fetchTemplates();

  Future<void> _fetchTemplates() async {
    setState(() => _isFetchingTemplates = true);
    try {
      final result = await widget.biometricDevicesRepository.getDeviceTemplates(
        widget.device.id,
      );
      result.fold(
        (failure) =>
            widget.onShowSnack(failure.message, color: Theme.of(context).colorScheme.error),
        (templates) {
          if (mounted) setState(() => _templates = templates);
        },
      );
    } finally {
      if (mounted) setState(() => _isFetchingTemplates = false);
    }
  }

  Future<void> _deleteTemplate(DeviceFingerprint template) async {
    final result = await widget.biometricDevicesRepository.deleteDeviceTemplate(
      widget.device.id,
      template.uid,
      template.mark,
      template.uid.toString(),
    );
    result.fold(
      (failure) => widget.onShowSnack(failure.message, color: Theme.of(context).colorScheme.error),
      (_) {
        widget.onShowSnack('تم حذف البصمة بنجاح');
        _fetchTemplates();
      },
    );
  }

  void _confirmDeleteTemplate(DeviceFingerprint template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDeleteDialog(
        title: 'تأكيد حذف البصمة',
        content: 'هل أنت متأكد من حذف بصمة الموظف "${template.uid}"؟',
        confirmText: 'حذف',
      ),
    );
    if (confirmed == true) {
      _deleteTemplate(template);
    }
  }

  Future<void> _exportTemplatesCsv() async {
    final data = _templates;
    if (data.isEmpty) return;

    final loc = AppLocalizations.of(context);
    final headers = [loc!.employeeId, loc.size, loc.status, loc.flag];
    final rows = data.map((t) {
      return [
        '${t.uid}',
        '${t.size}',
        t.valid == 1 ? AppLocalizations.of(context)!.valid : AppLocalizations.of(context)!.invalid,
        '${t.mark}',
      ];
    }).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final bom = '\uFEFF$csvData';

    final path = await FilePicker.platform.saveFile(
      fileName: 'device_templates.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path != null) {
      await File(path).writeAsString(bom);
      if (mounted) {
        widget.onShowSnack('تم تصدير التقرير بنجاح');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConnectionHeader(),
          Row(
            children: [
              Text(
                'بصمات الموظفين',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_templates.isNotEmpty) ...[
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
                    '${_templates.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_templates.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _exportTemplatesCsv,
                  icon: Icon(Icons.table_chart_outlined, size: 18),
                  label: Text(AppLocalizations.of(context)!.excel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isFetchingTemplates ? null : _fetchTemplates,
                icon: _isFetchingTemplates
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh, size: 18),
                label: Text(AppLocalizations.of(context)!.download),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          Divider(),
          Expanded(
            child: _templates.isEmpty
                ? Center(
                    child: Text(
                      _isFetchingTemplates
                          ? AppLocalizations.of(context)!.loading
                          : AppLocalizations.of(context)!.noTemplates,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : buildTemplatesTable(),
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

  TableWidget<DeviceFingerprint> buildTemplatesTable() {
    return TableWidget<DeviceFingerprint>(
      header: [
        AppLocalizations.of(context)!.employeeId,
        AppLocalizations.of(context)!.size,
        AppLocalizations.of(context)!.status,
        AppLocalizations.of(context)!.flag,
        AppLocalizations.of(context)!.delete,
      ],
      columns: const {
        0: FixedTableWidgetColumnWidth(120),
        1: FixedTableWidgetColumnWidth(100),
        2: FixedTableWidgetColumnWidth(100),
        3: FixedTableWidgetColumnWidth(100),
        4: FixedTableWidgetColumnWidth(60),
      },
      items: _templates,
      builder: (context, template, index) {
        return [
          Text('${template.uid}'),
          Text('${template.size}'),
          Text(
            template.valid == 1 ? AppLocalizations.of(context)!.valid : AppLocalizations.of(context)!.invalid,
            style: TextStyle(
              color: template.valid == 1 ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('${template.mark}'),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            tooltip: AppLocalizations.of(context)!.delete,
            onPressed: () => _confirmDeleteTemplate(template),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ];
      },
    );
  }
}
