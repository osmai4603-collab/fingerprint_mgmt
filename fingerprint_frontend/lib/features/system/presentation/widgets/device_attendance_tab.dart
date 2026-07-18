import 'dart:io';
import 'package:fingerprint_frontend/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DeviceAttendanceTab extends StatefulWidget {
  final BiometricDeviceModel device;
  final AttendanceLogsRepository attendanceLogsRepository;
  final bool isConnected;
  final void Function(String message, {Color? color}) onShowSnack;

  const DeviceAttendanceTab({
    super.key,
    required this.device,
    required this.attendanceLogsRepository,
    required this.isConnected,
    required this.onShowSnack,
  });

  @override
  State<DeviceAttendanceTab> createState() => DeviceAttendanceTabState();
}

class DeviceAttendanceTabState extends State<DeviceAttendanceTab> {
  final _data = _AttendanceTabData();
  late final _AttendanceCsvExport _csvExport;
  //  = _AttendanceCsvExport();
  late BiometricDeviceEntity device;

  Future<void> _fetchAttendance() async {
    _data.isLoading = true;
    final resultOfDevice = await get_it<BiometricDevicesRepository>().getById(
      widget.device.id,
    );
    device = resultOfDevice.fold((f) => widget.device, (r) => r);
    if (mounted) setState(() {});
    try {
      final result = await widget.attendanceLogsRepository.getDeviceAttendance(
        widget.device.id,
        startDate: device.lastRequestDate,
      );
      result.fold(
        (failure) => widget.onShowSnack(
          failure.message,
          color: Theme.of(context).colorScheme.error,
        ),
        (logs) {
          if (mounted) {
            _data.updateLogs(logs);
            widget.onShowSnack('تم استرجاع ${_data.logs.length} سجل بنجاح');
          }
        },
      );
    } finally {
      _data.isLoading = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> syncAttendance() async {
    if (_data.logs.isEmpty) return;
    if (!widget.isConnected) {
      widget.onShowSnack(
        'الرجاء الاتصال بالجهاز أولاً',
        color: Theme.of(context).colorScheme.error,
      );
      return;
    }

    _data.isSyncing = true;
    if (mounted) setState(() {});
    try {
      final result = await _AttendanceSyncService.execute(
        attendanceLogs: _data.logs,
        deviceId: widget.device.id,
        attendanceLogsRepository: widget.attendanceLogsRepository,
        onShowSnack: widget.onShowSnack,
      );
      final now = DateTime.now();
      _data.lastRequestDate = now;
      final deviceRepo = GetIt.instance<BiometricDevicesRepository>();
      deviceRepo.update(widget.device.copyWith(lastRequestDate: now));

      if (mounted) {
        widget.onShowSnack(
          result.hasFailures
              ? 'تمت المزامنة: ${result.created} إضافة، ${result.skipped} موجود مسبقاً، ${result.noEmployee} بدون موظف، ${result.failed} فشل'
              : 'تمت المزامنة بنجاح: ${result.created} سجل جديد، ${result.skipped} موجود مسبقاً',
          color: result.hasFailures
              ? Theme.of(context).colorScheme.lateStatus
              : null,
        );
        _fetchAttendance();
      }
    } finally {
      _data.isSyncing = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> exportCsv() async {
    await _csvExport.execute(logs: _data.logs, onShowSnack: widget.onShowSnack);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _csvExport = _AttendanceCsvExport(AppLocalizations.of(context)!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              Divider(),
              Expanded(
                child: _data.logs.isEmpty
                    ? Center(
                        child: Text(
                          _data.isLoading ? 'جارٍ التحميل...' : 'لا توجد سجلات',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildAttendanceLogsTable(),
              ),
            ],
          ),
        ),
        if (_data.isSyncing) _buildSyncOverlay(),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Text(
          'حركات البصمة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (_data.logs.isNotEmpty) ...[
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_data.logs.length}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (widget.isConnected && _data.logs.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _data.isSyncing ? null : syncAttendance,
              icon: _data.isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    )
                  : Icon(Icons.sync, size: 18),
              label: Text(AppLocalizations.of(context)!.sync),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.success,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        if (_data.logs.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _data.logs.isEmpty ? null : exportCsv,
              icon: Icon(Icons.table_chart_outlined, size: 18),
              label: Text(AppLocalizations.of(context)!.excel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: _data.isLoading ? null : _fetchAttendance,
          icon: _data.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.download, size: 18),
          label: Text(AppLocalizations.of(context)!.download),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncOverlay() {
    return Container(
      color: Colors.black.withAlpha(80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 12),
            Text(
              'جارٍ مزامنة السجلات...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableWidget<DeviceAttendanceLog> _buildAttendanceLogsTable() {
    return TableWidget<DeviceAttendanceLog>(
      header: [
        AppLocalizations.of(context)!.employeeCodeLabel,
        AppLocalizations.of(context)!.stateLabel,
        AppLocalizations.of(context)!.typeLabel,
        AppLocalizations.of(context)!.dateTimeLabel,
      ],
      columns: const {
        0: FixedTableWidgetColumnWidth(120),
        1: FlexTableWidgetColumnWidth(1),
        2: FlexTableWidgetColumnWidth(1),
        3: FixedTableWidgetColumnWidth(180),
      },
      items: _data.logs,
      builder: (context, log, index) {
        return [
          Text(log.userId.isEmpty ? '---' : log.userId),
          Text(log.status.attendanceStateLabel),
          Text(log.punchType.attendanceTypeLabel),
          Text(formatAttendanceDateTime(log.timestamp)),
        ];
      },
    );
  }
}

class _AttendanceTabData {
  List<DeviceAttendanceLog> logs = [];
  bool isLoading = false;
  bool isSyncing = false;
  DateTime? lastRequestDate;

  void updateLogs(List<DeviceAttendanceLog> newLogs) {
    logs = newLogs;
    lastRequestDate = DateTime.now();
  }
}

class _AttendanceSyncResult {
  final int created;
  final int failed;
  final int skipped;
  final int noEmployee;

  const _AttendanceSyncResult({
    this.created = 0,
    this.failed = 0,
    this.skipped = 0,
    this.noEmployee = 0,
  });

  bool get hasFailures => failed > 0;
}

class _AttendanceSyncService {
  static Future<_AttendanceSyncResult> execute({
    required List<DeviceAttendanceLog> attendanceLogs,
    required int deviceId,
    required AttendanceLogsRepository attendanceLogsRepository,
    required void Function(String, {Color? color}) onShowSnack,
  }) async {
    final employeeMap = await _loadEmployeeMap();
    final groupedLogs = _groupLogsByEmployeeDate(attendanceLogs);

    int created = 0;
    int failed = 0;
    int skipped = 0;
    int noEmployee = 0;

    for (final entry in groupedLogs.entries) {
      final logs = entry.value;
      final firstLog = logs.first;
      final employee = employeeMap[firstLog.userId];

      if (employee == null) {
        noEmployee += logs.length;
        continue;
      }

      final groupDate = firstLog.timestamp;
      final existingDbLogs = await _loadExistingLogs(
        attendanceLogsRepository,
        employee.uid,
        groupDate,
      );

      for (final log in logs) {
        final punchTime = log.timestamp;
        if (punchTime == null) {
          failed++;
          continue;
        }

        final exists = existingDbLogs.any((dbLog) {
          final diff = dbLog.punchTime.difference(punchTime).inMinutes.abs();
          return diff <= 1;
        });

        if (exists) {
          skipped++;
          continue;
        }

        final result = await attendanceLogsRepository.create(
          AttendanceLogEntity(
            id: 0,
            employeeId: employee.uid,
            deviceId: deviceId,
            punchTime: punchTime,
          ),
        );
        result.fold((_) => failed++, (_) => created++);
      }
    }

    return _AttendanceSyncResult(
      created: created,
      failed: failed,
      skipped: skipped,
      noEmployee: noEmployee,
    );
  }

  static Future<Map<String, EmployeeModel>> _loadEmployeeMap() async {
    final empRepo = GetIt.instance<EmployeeRepository>();
    final Map<String, EmployeeModel> map = {};
    final result = await empRepo.getActiveEmployees();
    result.fold((_) {}, (employees) {
      for (final emp in employees) {
        map[emp.employeeID] = emp;
      }
    });
    return map;
  }

  static Map<String, List<DeviceAttendanceLog>> _groupLogsByEmployeeDate(
    List<DeviceAttendanceLog> logs,
  ) {
    final grouped = <String, List<DeviceAttendanceLog>>{};
    for (final log in logs) {
      final punchTime = log.timestamp;
      final dateKey = punchTime != null
          ? '${log.userId}_${punchTime.year}${punchTime.month.toString().padLeft(2, '0')}${punchTime.day.toString().padLeft(2, '0')}'
          : '${log.userId}_unknown';
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }
    return grouped;
  }

  static Future<List<AttendanceLogModel>> _loadExistingLogs(
    AttendanceLogsRepository repository,
    int employeeId,
    DateTime? groupDate,
  ) async {
    if (groupDate == null) return [];
    final result = await repository.getAttendanceLogs(
      employeeId: employeeId,
      fromDate: groupDate,
      toDate: groupDate,
    );
    final List<AttendanceLogModel> logs = [];
    result.fold((_) {}, (dbLogs) => logs.addAll(dbLogs));
    return logs;
  }
}

class _AttendanceCsvExport {
  _AttendanceCsvExport(this.loc);
  final AppLocalizations loc;
  Future<void> execute({
    required List<DeviceAttendanceLog> logs,
    required void Function(String, {Color? color}) onShowSnack,
  }) async {
    if (logs.isEmpty) return;

    final headers = [
      loc.employeeCodeLabel,
      loc.stateLabel,
      loc.typeLabel,
      loc.dateTimeLabel,
    ];
    final rows = logs.map((log) {
      return [
        log.userId.isEmpty ? '---' : log.userId,
        log.status.attendanceStateLabel,
        log.punchType.attendanceTypeLabel,
        formatAttendanceDateTime(log.timestamp),
      ];
    }).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final bom = '\uFEFF$csvData';

    final path = await FilePicker.platform.saveFile(
      fileName: 'device_attendance_logs.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path != null) {
      await File(path).writeAsString(bom);
      onShowSnack('تم تصدير التقرير بنجاح');
    }
  }
}

extension _AttendanceStateLabel on int {
  String get attendanceStateLabel {
    return switch (this) {
      0 => 'دخول',
      1 => 'خروج',
      2 => 'بدء استراحة',
      3 => 'نهاية استراحة',
      4 => 'عمل إضافي دخول',
      5 => 'عمل إضافي خروج',
      _ => '$this',
    };
  }

  String get attendanceTypeLabel {
    return switch (this) {
      0 => 'بصمة',
      1 => 'كلمة سر',
      2 => 'بطاقة',
      3 => 'بصمة+كلمة سر',
      _ => '$this',
    };
  }
}

String formatAttendanceDateTime(DateTime? dt) {
  if (dt == null) return '---';
  return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}
