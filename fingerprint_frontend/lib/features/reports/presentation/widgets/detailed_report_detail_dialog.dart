import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/di/injection_container.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class DetailedReportDetailDialog extends StatefulWidget {
  final DetailedDailyReport report;

  const DetailedReportDetailDialog({super.key, required this.report});

  static Future<void> show(BuildContext context, DetailedDailyReport report) {
    return showDialog(
      context: context,
      builder: (_) => DetailedReportDetailDialog(report: report),
    );
  }

  @override
  State<DetailedReportDetailDialog> createState() =>
      _DetailedReportDetailDialogState();
}

class _DetailedReportDetailDialogState
    extends State<DetailedReportDetailDialog> {
  final AttendanceLogsRepository _logsRepo = get_it<AttendanceLogsRepository>();
  List<AttendanceLogModel>? _logs;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final date = widget.report.date;
    final result = await _logsRepo.getAttendanceLogs(
      employeeId: widget.report.employeeId,
      fromDate: date,
      toDate: date,
    );
    result.fold(
      (failure) => setState(() {
        _error = failure.message;
        _loading = false;
      }),
      (logs) => setState(() {
        _logs = logs;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final r = widget.report;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 650,
        constraints: const BoxConstraints(maxHeight: 750),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.3),
              colors.surface,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildEmployeeInfo(theme, r)),
                SizedBox(width: 16),
                Expanded(child: _buildShiftInfo(theme, r)),
              ],
            ),
            SizedBox(height: 20),
            Divider(height: 1),
            SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.rawFingerprintRecords,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(child: _buildLogsContent()),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                label: Text(AppLocalizations.of(context)!.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfo(ThemeData theme, DetailedDailyReport r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.badge_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.employeeData,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(AppLocalizations.of(context)!.name, r.employeeName),
              SizedBox(height: 8),
              _buildInfoRow(
                AppLocalizations.of(context)!.employeeCode,
                r.employeeId.toString(),
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                AppLocalizations.of(context)!.attendanceStatus,
                r.attendanceStatus ?? '---',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftInfo(ThemeData theme, DetailedDailyReport r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.shiftData,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                AppLocalizations.of(context)!.dateLabel,
                r.date != null ? formatDate(r.date!) : '---',
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                AppLocalizations.of(context)!.shiftLabel,
                r.shiftName ?? '---',
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                AppLocalizations.of(context)!.attendanceTime,
                r.attendanceTime != null
                    ? formatTime(r.attendanceTime!)
                    : '---',
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                AppLocalizations.of(context)!.departureTime,
                r.departureTime != null ? formatTime(r.departureTime!) : '---',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogsContent() {
    if (_loading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: ShimmerLoading.logRows(rows: 4),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.errorLoadingRecords(_error!),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    if (_logs == null || _logs!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(AppLocalizations.of(context)!.noRecordsForEmployee),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLogsHeader(),
          Divider(height: 1),
          ...List.generate(_logs!.length, (index) {
            final log = _logs![index];
            final isLast = index == _logs!.length - 1;
            return _buildLogRow(log, index, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildLogsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          _logCol(AppLocalizations.of(context)!.tableNo, 40),
          _logCol(AppLocalizations.of(context)!.dateLabel, 120),
          _logCol(AppLocalizations.of(context)!.dateTime, 120),
          _logCol('اليوم', 80),
          _logCol(AppLocalizations.of(context)!.device, 60),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildLogRow(AttendanceLogModel log, int index, bool isLast) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
      ),
      child: Row(
        children: [
          _logCol('${index + 1}', 40),
          _logCol(formatDate(log.punchTime), 120),
          _logCol(formatTime(log.punchTime), 120),
          _logCol(getDayName(log.punchTime), 80),
          _logCol(log.deviceId?.toString() ?? '---', 60),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _logCol(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: TextStyle(fontSize: 13),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: value == '---' || value == '00:00 ساعة'
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
