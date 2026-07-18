import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/device/biometric_device_controller.dart';
import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DevicePropertiesTab extends StatefulWidget {
  final BiometricDeviceModel device;
  final BiometricDeviceController controller;
  final BiometricDevicesRepository biometricDevicesRepository;
  final AttendanceLogsRepository attendanceLogsRepository;
  final bool isConnected;
  final bool isConnecting;
  final bool isExecuting;
  final String? lastSyncTime;
  final DateTime? lastRequestDate;
  final void Function(String message, {Color? color}) onShowSnack;
  final ValueChanged<String?> onLastSyncTimeChanged;

  const DevicePropertiesTab({
    super.key,
    required this.device,
    required this.controller,
    required this.biometricDevicesRepository,
    required this.attendanceLogsRepository,
    required this.isConnected,
    required this.isConnecting,
    required this.isExecuting,
    this.lastSyncTime,
    this.lastRequestDate,
    required this.onShowSnack,
    required this.onLastSyncTimeChanged,
  });

  @override
  State<DevicePropertiesTab> createState() => DevicePropertiesTabState();
}

class DevicePropertiesTabState extends State<DevicePropertiesTab> {
  String? _deviceName;
  String? _version;
  String? _serialNumber;
  String? _deviceTime;
  String? _mac;
  Map<String, dynamic>? _networkParams;
  bool _isFetchingProps = false;
  String? _firmwareVersionOnConnect;
  String? _serialNumberOnConnect;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() => _fetchDeviceInfo();

  Future<void> _fetchDeviceInfo() async {
    final version = await widget.controller.getFirmwareVersion();
    final serial = await widget.controller.getSerialNumber();
    if (mounted) {
      setState(() {
        _firmwareVersionOnConnect = version;
        _serialNumberOnConnect = serial;
      });
    }
  }

  Future<void> fetchProperties() => _fetchProperties();

  Future<void> _fetchProperties() async {
    if (!widget.isConnected) {
      widget.onShowSnack(
        'الرجاء الاتصال بالجهاز أولاً',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    setState(() => _isFetchingProps = true);
    try {
      final props = await widget.controller.getAllProperties();
      if (mounted && props != null) {
        setState(() {
          _deviceName = props['deviceName']?.toString();
          _version = props['firmwareVersion']?.toString();
          _serialNumber = props['serialNumber']?.toString();
          _deviceTime = props['time']?.toString();
          _mac = props['mac']?.toString();
          _networkParams = props['networkParams'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      widget.onShowSnack('فشل جلب خصائص الجهاز: $e', color: Theme.of(context).colorScheme.error);
    } finally {
      if (mounted) setState(() => _isFetchingProps = false);
    }
  }

  Future<void> syncData() => _syncData();

  Future<void> _syncData() async {
    if (!widget.isConnected) {
      widget.onShowSnack(
        'الرجاء الاتصال بالجهاز أولاً',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }
    setState(() => _isSyncing = true);
    try {
      final result = await widget.attendanceLogsRepository.syncDeviceData(
        widget.device.id,
      );
      result.fold(
        (failure) => widget.onShowSnack(
          'فشل المزامنة: ${failure.message}',
          color: Theme.of(context).colorScheme.error,
        ),
        (data) {
          final newLogs = data['new_logs_count'];
          widget.onShowSnack('تمت المزامنة بنجاح. السجلات الجديدة: $newLogs');
          if (mounted) {
            setState(() {
              widget.onLastSyncTimeChanged(data['last_sync']?.toString());
            });
          }
        },
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _clearData() async {
    final success = await widget.controller.clearData();
    if (success) {
      widget.onShowSnack('تم مسح جميع بيانات الجهاز');
    } else {
      widget.onShowSnack('فشل مسح البيانات', color: Theme.of(context).colorScheme.error);
    }
  }

  void _confirmClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDeleteDialog(
        title: 'تأكيد مسح كل البيانات',
        content:
            'هل أنت متأكد من مسح جميع البيانات من الجهاز؟\nهذا الإجراء لا يمكن التراجع عنه!',
        confirmText: 'مسح الكل',
      ),
    );
    if (confirmed == true) {
      _clearData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.isConnected;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: colors.surfaceContainerHighest,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'معلومات الجهاز الأساسية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (isConnected)
                          ElevatedButton.icon(
                            onPressed: _isSyncing ? null : _syncData,
                            icon: _isSyncing
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.sync, size: 18),
                            label: Text(AppLocalizations.of(context)!.syncData),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                    Divider(),
                    _buildInfoRow(AppLocalizations.of(context)!.deviceId, widget.device.id.toString()),
                    _buildInfoRow(AppLocalizations.of(context)!.deviceName, widget.device.name),
                    _buildInfoRow(AppLocalizations.of(context)!.ipAddress, widget.device.ipAddress),
                    _buildInfoRow(AppLocalizations.of(context)!.port, widget.device.port.toString()),
                    _buildInfoRow(
                      AppLocalizations.of(context)!.status,
                      widget.device.isOnline ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnected,
                    ),
                    _buildInfoRow(
                      AppLocalizations.of(context)!.lastSync,
                      widget.lastSyncTime ?? AppLocalizations.of(context)!.notSynced,
                    ),
                    _buildInfoRow(
                      AppLocalizations.of(context)!.lastRequestDate,
                      widget.lastRequestDate != null
                          ? '${widget.lastRequestDate!.year}-${widget.lastRequestDate!.month.toString().padLeft(2, '0')}-${widget.lastRequestDate!.day.toString().padLeft(2, '0')}'
                          : AppLocalizations.of(context)!.noRequestMade,
                    ),
                    _buildInfoRow(
                      AppLocalizations.of(context)!.firmwareVersion,
                      _firmwareVersionOnConnect ?? AppLocalizations.of(context)!.notAvailable,
                    ),
                    _buildInfoRow(
                      AppLocalizations.of(context)!.serialNumber,
                      _serialNumberOnConnect ?? AppLocalizations.of(context)!.notAvailable,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            if (isConnected) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'خصائص الجهاز من الجهاز نفسه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _isFetchingProps
                                ? null
                                : _fetchProperties,
                            icon: _isFetchingProps
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.refresh, size: 18),
                            label: Text(AppLocalizations.of(context)!.fetchProperties),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      _buildInfoRow(AppLocalizations.of(context)!.deviceName, _deviceName),
                      _buildInfoRow(AppLocalizations.of(context)!.firmwareVersion, _version),
                      _buildInfoRow(AppLocalizations.of(context)!.serialNumber, _serialNumber),
                      _buildInfoRow('وقت الجهاز', _deviceTime ?? '---'),
                      _buildInfoRow('عنوان MAC', _mac),
                      if (_networkParams != null) ...[
                        _buildInfoRow(
                          'عنوان IP',
                          _networkParams!['ip']?.toString(),
                        ),
                        _buildInfoRow(
                          'قنات الشبكة',
                          _networkParams!['gateway']?.toString(),
                        ),
                        _buildInfoRow(
                          'قنات الاتصال',
                          _networkParams!['dns']?.toString(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التحكم عن بُعد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _actionButton(
                            label: 'تفعيل',
                            icon: Icons.play_arrow,
                            color: Theme.of(context).colorScheme.success,
                            onTap: () async {
                              final ok = await widget.controller.enableDevice();
                              widget.onShowSnack(
                                ok ? 'تم تفعيل الجهاز' : 'فشل التفعيل',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                          _actionButton(
                            label: 'تعطيل',
                            icon: Icons.pause,
                            color: Theme.of(context).colorScheme.error,
                            onTap: () async {
                              final ok = await widget.controller
                                  .disableDevice();
                              widget.onShowSnack(
                                ok ? 'تم تعطيل الجهاز' : 'فشل التعطيل',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                          _actionButton(
                            label: 'إعادة تشغيل',
                            icon: Icons.restart_alt,
                            color: Theme.of(context).colorScheme.lateStatus,
                            onTap: () async {
                              final ok = await widget.controller.restart();
                              widget.onShowSnack(
                                ok
                                    ? 'تم إرسال أمر إعادة التشغيل'
                                    : 'فشل إعادة التشغيل',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                          _actionButton(
                            label: 'اختبار الصوت',
                            icon: Icons.volume_up,
                            color: Theme.of(context).colorScheme.primary,
                            onTap: () async {
                              final ok = await widget.controller.testVoice();
                              widget.onShowSnack(
                                ok
                                    ? 'تم تشغيل الصوت التجريبي'
                                    : 'فشل اختبار الصوت',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                          _actionButton(
                            label: 'فتح القفل',
                            icon: Icons.lock_open,
                            color: Theme.of(context).colorScheme.success,
                            onTap: () async {
                              final ok = await widget.controller.unlock();
                              widget.onShowSnack(
                                ok ? 'تم فتح القفل' : 'فشل فتح القفل',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.error.withAlpha(15),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'أوامر التحكم بالجهاز',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _actionButton(
                            label: 'إيقاف التشغيل',
                            icon: Icons.power_settings_new,
                            color: Theme.of(context).colorScheme.error,
                            onTap: () async {
                              final ok = await widget.controller.poweroff();
                              widget.onShowSnack(
                                ok
                                    ? 'تم إرسال أمر إيقاف التشغيل'
                                    : 'فشل إيقاف التشغيل',
                                color: ok ? null : Theme.of(context).colorScheme.error,
                              );
                            },
                          ),
                          _actionButton(
                            label: 'مسح كل البيانات',
                            icon: Icons.delete_forever,
                            color: Theme.of(context).colorScheme.error,
                            onTap: () => _confirmClearData(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value ?? '---', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: widget.isExecuting ? null : onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(30),
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(80)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
