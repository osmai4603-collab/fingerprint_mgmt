import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/employee_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class SyncAttendanceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> deviceLogs;
  final int deviceId;

  const SyncAttendanceDialog({
    super.key,
    required this.deviceLogs,
    required this.deviceId,
  });

  static Future<void> show(
    BuildContext context,
    List<Map<String, dynamic>> deviceLogs,
    int deviceId,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SyncAttendanceDialog(deviceLogs: deviceLogs, deviceId: deviceId),
      ),
    );
  }

  @override
  State<SyncAttendanceDialog> createState() => _SyncAttendanceDialogState();
}

class _SyncItem {
  final Map<String, dynamic> log;
  final EmployeeModel? employee;

  bool existsInDb;
  bool isSelected;
  String? statusLabel;
  String? punchTypeLabel;
  String? formattedTime;
  final int deviceId;
  final int employeeId;
  final DateTime punchTime;

  _SyncItem({
    required this.log,
    this.employee,
    this.existsInDb = false,
    required this.isSelected,
    this.statusLabel,
    this.punchTypeLabel,
    this.formattedTime,
    required this.deviceId,
    required this.punchTime,
    required this.employeeId,
  });
}

class _SyncAttendanceDialogState extends State<SyncAttendanceDialog> {
  final _employeeRepo = GetIt.instance<EmployeeRepository>();
  final _attendanceRepo = GetIt.instance<AttendanceLogsRepository>();

  List<_SyncItem> _items = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _stateLabel(int state) {
    final loc = AppLocalizations.of(context);
    return switch (state) {
      0 => loc!.stateEntry,
      1 => loc!.stateExit,
      2 => loc!.stateBreakStart,
      3 => loc!.stateBreakEnd,
      4 => loc!.stateOvertimeIn,
      5 => loc!.stateOvertimeOut,
      _ => '$state',
    };
  }

  String _typeLabel(int type) {
    final loc = AppLocalizations.of(context);
    return switch (type) {
      0 => loc!.typeFingerprint,
      1 => loc!.typePassword,
      2 => loc!.typeCard,
      3 => loc!.typeFingerprintPassword,
      _ => '$type',
    };
  }

  String _formatDateTime(dynamic dt) {
    if (dt == null) return '---';
    final DateTime? dateTime = dt is DateTime
        ? dt
        : DateTime.tryParse(dt.toString().replaceAll('/', '-'));
    if (dateTime == null) return '---';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load all active employees for lookup
    final Map<String, EmployeeModel> employeeMap = {};
    final empResult = await _employeeRepo.getActiveEmployees();
    empResult.fold((_) {}, (employees) {
      for (final emp in employees) {
        employeeMap[emp.employeeID] = emp;
      }
    });

    // Check each log against DB
    final items = <_SyncItem>[];
    // Group by employee+date for batch checking
    final Map<String, List<Map<String, dynamic>>> groupedLogs = {};

    for (final log in widget.deviceLogs) {
      final userId = log['user_id']?.toString() ?? '';
      final timestamp = log['timestamp'];
      final DateTime? punchTime = timestamp is DateTime
          ? timestamp
          : DateTime.tryParse(timestamp?.toString() ?? '');
      final dateKey = punchTime != null
          ? '${userId}_${punchTime.year}${punchTime.month.toString().padLeft(2, '0')}${punchTime.day.toString().padLeft(2, '0')}'
          : '${userId}_unknown';

      groupedLogs.putIfAbsent(dateKey, () => []).add(log);
    }

    // For each group, query DB and check existence
    for (final entry in groupedLogs.entries) {
      final logs = entry.value;
      final firstLog = logs.first;
      final userId = firstLog['user_id']?.toString() ?? '';
      final employee = employeeMap[userId];

      // Get the date from the first log in the group
      DateTime? groupDate;
      final firstTimestamp = firstLog['timestamp'];
      if (firstTimestamp is DateTime) {
        groupDate = firstTimestamp;
      } else {
        groupDate = DateTime.tryParse(firstTimestamp?.toString() ?? '');
      }

      // Query DB logs for this employee on this date
      List<AttendanceLogModel> existingDbLogs = [];
      if (employee != null && groupDate != null) {
        final dbResult = await _attendanceRepo.getAttendanceLogs(
          employeeId: employee.uid,
          fromDate: groupDate,
          toDate: groupDate,
        );
        dbResult.fold((_) {}, (dbLogs) => existingDbLogs = dbLogs);
      }

      // Check each log in this group
      for (final log in logs) {
        final rawTimestamp = log['timestamp'];
        final DateTime? punchTime = rawTimestamp is DateTime
            ? rawTimestamp
            : DateTime.tryParse(rawTimestamp?.toString() ?? '');

        bool exists = false;
        if (employee != null && punchTime != null) {
          final pt = punchTime;
          exists = existingDbLogs.any((dbLog) {
            final diff = dbLog.punchTime.difference(pt).inMinutes.abs();
            return diff <= 1;
          });
        }

        final status = log['status'] as int? ?? -1;
        final punchType = log['punch_type'] as int? ?? -1;

        items.add(
          _SyncItem(
            log: log,
            employee: employee,
            existsInDb: exists,
            isSelected: !exists && employee != null,
            statusLabel: _stateLabel(status),
            punchTypeLabel: _typeLabel(punchType),
            formattedTime: _formatDateTime(log['timestamp']),
            deviceId: widget.deviceId,
            punchTime: punchTime!,
            employeeId: employee!.uid,
          ),
        );
      }
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
                  child: ShimmerLoading.table(rows: 20, columns: 6),
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
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.syncAttendanceRecords,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.recordsInDevice(widget.deviceLogs.length),
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
              AppLocalizations.of(context)!.employeeCodeLabel,
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppLocalizations.of(context)!.employee,
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppLocalizations.of(context)!.dateTimeLabel,
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              AppLocalizations.of(context)!.stateLabel,
              style: styles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              AppLocalizations.of(context)!.inDatabase,
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
    final employeeNotFound = item.employee == null;
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
            onChanged: (item.existsInDb || employeeNotFound)
                ? null
                : (v) => setState(() => item.isSelected = v ?? true),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.log['user_id']?.toString() ?? '---',
              textAlign: TextAlign.center,
              style: styles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              employeeNotFound ? AppLocalizations.of(context)!.notFoundInDb : item.employee!.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: employeeNotFound ? Theme.of(context).colorScheme.error : null,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatDateTime(item.punchTime),
              textAlign: TextAlign.center,
              style: styles.bodySmall,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item.statusLabel ?? '---',
              textAlign: TextAlign.center,
              style: styles.bodySmall,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(child: _buildStatusBadge(item, employeeNotFound)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(_SyncItem item, bool employeeNotFound) {
    if (employeeNotFound) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppLocalizations.of(context)!.noEmployee,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
    if (item.existsInDb) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.success.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          AppLocalizations.of(context)!.existingLabel,
          style: TextStyle(
            color: Theme.of(context).colorScheme.success,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.lateStatus.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppLocalizations.of(context)!.newLabel,
        style: TextStyle(
          color: Theme.of(context).colorScheme.lateStatus,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBottomBar(TextTheme styles) {
    final selectedCount = _items
        .where((i) => i.isSelected && i.employee != null && !i.existsInDb)
        .length;
    final noEmployeeCount = _items.where((i) => i.employee == null).length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.syncResultSummary(selectedCount, noEmployeeCount),
                style: styles.bodyMedium,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: _isSyncing
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              SizedBox(width: 12),
              FilledButton.icon(
                onPressed: (selectedCount == 0 || _isSyncing) ? null : _sync,
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
                label: Text(
                  _isSyncing ? AppLocalizations.of(context)!.syncing : AppLocalizations.of(context)!.syncAttendanceBtn,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          if (noEmployeeCount > 0)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                AppLocalizations.of(context)!.recordsWithoutEmployeeWarning,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  String _stateFromStatus(int status) {
    return switch (status) {
      0 => 'in',
      1 => 'out',
      2 => 'break_start',
      3 => 'break_end',
      4 => 'overtime_in',
      5 => 'overtime_out',
      _ => 'in',
    };
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);

    int created = 0;
    int failed = 0;
    int skipped = 0;

    for (final item in _items) {
      if (!item.isSelected || item.employee == null || item.existsInDb) {
        if (!item.isSelected) skipped++;
        continue;
      }

      // final rawTimestamp = item.log['timestamp'];
      // final DateTime? punchTime = rawTimestamp is DateTime
      //     ? rawTimestamp
      //     : DateTime.tryParse(rawTimestamp?.toString() ?? '');

      // if (punchTime == null) {
      //   failed++;
      //   continue;
      // }

      final result = await _attendanceRepo.create(
        AttendanceLogEntity(
          id: 0,
          employeeId: item.employeeId,
          deviceId: widget.deviceId,
          punchTime: item.punchTime,
        ),
      );
      result.fold((_) {
        print(
          AttendanceLogModel(
            id: 0,
            employeeId: item.employeeId,
            deviceId: widget.deviceId,
            punchTime: item.punchTime,
          ).toMap(),
        );
        failed++;
      }, (_) => created++);
    }

    if (!mounted) return;

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed > 0
              ? loc!.syncAttendanceResult(created, skipped, failed)
              : loc!.syncAttendanceResultSuccess(created, skipped),
        ),
        backgroundColor: failed > 0 ? Theme.of(context).colorScheme.lateStatus : Theme.of(context).colorScheme.success,
      ),
    );

    setState(() => _isSyncing = false);
    Navigator.of(context).pop(true);
  }
}
