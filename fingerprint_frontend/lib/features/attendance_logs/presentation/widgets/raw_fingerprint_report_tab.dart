import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import '../../../../core/widgets/table_widget.dart';
import '../../../../core/shared/shared_core.dart';
import '../../../attendance/presentation/bloc/attendance_bloc.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';
import 'raw_fingerprint_detail_dialog.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class RawFingerprintReportTab extends StatefulWidget {
  const RawFingerprintReportTab({super.key});

  @override
  State<RawFingerprintReportTab> createState() =>
      _RawFingerprintReportTabState();
}

class _RawFingerprintReportTabState extends State<RawFingerprintReportTab> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedEmployeeId;
  final _searchController = TextEditingController();
  final List<DailyAttendanceEmployeeReport> _allReportData = [];

  void _loadReport() {
    context.read<AttendanceBloc>().add(
      LoadRawLogsEvent(employeeId: _selectedEmployeeId),
    );
  }

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    _loadReport();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DailyAttendanceEmployeeReport> _applySearch(
    List<DailyAttendanceEmployeeReport> data,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return data;
    return data
        .where((r) => r.employeeName.toLowerCase().startsWith(query))
        .toList();
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
                    _loadReport();
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
                    _loadReport();
                  }
                },
                icon: Icon(Icons.calendar_today),
                label: Text(
                  '${AppLocalizations.of(context)!.toDate}: ${_toDate == null ? AppLocalizations.of(context)!.dash : formatDate(_toDate!)}',
                ),
              ),
              SizedBox(width: 16),
              BlocBuilder<EmployeesBloc, EmployeesState>(
                builder: (context, state) {
                  if (state is EmployeesLoaded) {
                    return SizedBox(
                      width: 250,
                      child: DropdownButtonFormField<int?>(
                        initialValue: _selectedEmployeeId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                            child: Text(AppLocalizations.of(context)!.allEmployees),
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
                          _loadReport();
                        },
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _loadReport,
                icon: Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.refresh),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _exportCsv(),
                icon: Icon(Icons.table_chart_outlined),
                label: Text(AppLocalizations.of(context)!.excel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.success,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _exportPdf(),
                icon: Icon(Icons.picture_as_pdf_outlined),
                label: Text(AppLocalizations.of(context)!.pdf),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            buildWhen: (previous, current) =>
                current is AttendanceLoading || current is AttendanceError,
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return Center(
                  child: ShimmerLoading.table(rows: 20, columns: 9),
                );
              }

              if (state is AttendanceError) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return Center(child: Text(AppLocalizations.of(context)!.dash));
            },
          ),
        ),
      ],
    );
  }

  Future<void> _exportCsv() async {
    final data = _allReportData;
    if (data.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final headers = [
      l10n.tableNo,
      l10n.employeeName,
      l10n.shiftLabel,
      l10n.dateLabel,
      l10n.status,
      l10n.firstFingerprint,
      l10n.lastFingerprint,
      l10n.totalHours,
      l10n.fingerprintCount,
    ];
    final rows = data.asMap().entries.map((e) {
      final r = e.value;
      return [
        '${e.key + 1}',
        r.employeeName,
        r.shiftName ?? l10n.dash,
        formatDate(r.date),
        r.status?.label ?? l10n.dash,
        r.formattedFirstPunchTime,
        r.punchCount <= 1 ? l10n.dash : r.formattedLastPunchTime,
        r.punchCount <= 1 ? '00:00 ساعة' : r.formattedTotalHours,
        '${r.punchCount}',
      ];
    }).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);
    final bom = '\uFEFF$csvData';

    final path = await FilePicker.platform.saveFile(
      fileName: 'fingerprint_report.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path != null) {
      await File(path).writeAsString(bom);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.reportExported)));
      }
    }
  }

  Future<void> _exportPdf() async {
    final data = _allReportData;
    if (data.isEmpty) return;

    final fontData = await rootBundle.load(
      'fonts/Noto_Naskh_Arabic/NotoNaskhArabic-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(fontData);

    final l10n = AppLocalizations.of(context)!;
    final headers = [
      l10n.tableNo,
      l10n.employeeName,
      l10n.shiftLabel,
      l10n.dateLabel,
      l10n.status,
      l10n.firstFingerprint,
      l10n.lastFingerprint,
      l10n.totalHours,
      l10n.fingerprintCount,
    ];
    final rows = data.asMap().entries.map((e) {
      final r = e.value;
      return [
        '${e.key + 1}',
        r.employeeName,
        r.shiftName ?? l10n.dash,
        formatDate(r.date),
        r.status?.label ?? l10n.dash,
        r.formattedFirstPunchTime,
        r.punchCount <= 1 ? l10n.dash : r.formattedLastPunchTime,
        r.punchCount <= 1 ? '00:00 ساعة' : r.formattedTotalHours,
        '${r.punchCount}',
      ];
    }).toList();

    final numericCols = {0, 7, 8};

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'تقرير البصمات',
              style: pw.TextStyle(font: arabicFont),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(100),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(80),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(80),
                6: const pw.FixedColumnWidth(80),
                7: const pw.FixedColumnWidth(60),
                8: const pw.FixedColumnWidth(50),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFE0E0E0),
                  ),
                  children: headers.reversed
                      .map(
                        (h) => pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...rows.map(
                  (row) => pw.TableRow(
                    children: row.asMap().entries.toList().reversed.map((e) {
                      final isNumeric = numericCols.contains(e.key);
                      return pw.Container(
                        alignment: isNumeric
                            ? pw.Alignment.centerLeft
                            : pw.Alignment.centerRight,
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          e.value,
                          style: pw.TextStyle(font: arabicFont, fontSize: 8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final path = await FilePicker.platform.saveFile(
      fileName: 'fingerprint_report.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.reportExported)));
      }
    }
  }

  Map<int, TableWidgetColumnWidth> get _columns => {
    0: FixedTableWidgetColumnWidth(40, alignment: Alignment.center),
    1: FlexTableWidgetColumnWidth(5, alignment: .centerStart),
    2: FixedTableWidgetColumnWidth(220, alignment: Alignment.center),
    3: FixedTableWidgetColumnWidth(140, alignment: Alignment.center),
    4: FixedTableWidgetColumnWidth(80, alignment: Alignment.center),
    5: FixedTableWidgetColumnWidth(100, alignment: Alignment.center),
    6: FixedTableWidgetColumnWidth(100, alignment: Alignment.center),
    7: FixedTableWidgetColumnWidth(90, alignment: Alignment.center),
    8: FixedTableWidgetColumnWidth(80, alignment: Alignment.center),
  };

  List<String> get _headers => [
    AppLocalizations.of(context)!.tableNo,
    AppLocalizations.of(context)!.employeeName,
    AppLocalizations.of(context)!.shiftLabel,
    AppLocalizations.of(context)!.dateLabel,
    AppLocalizations.of(context)!.status,
    AppLocalizations.of(context)!.firstFingerprint,
    AppLocalizations.of(context)!.lastFingerprint,
    AppLocalizations.of(context)!.totalHours,
    AppLocalizations.of(context)!.fingerprintCount,
  ];

  Widget _buildReportTable(List<DailyAttendanceEmployeeReport> data) {
    final validStatuses = {
      AttendanceReviewStatus.excellent,
      AttendanceReviewStatus.acceptable,
      AttendanceReviewStatus.late,
    };
    final attendanceDays = data
        .where((r) => r.status != null && validStatuses.contains(r.status))
        .map((r) => r.date.toIso8601String().split('T')[0])
        .toSet()
        .length;
    final totalHours = data.fold<double>(0, (sum, r) => sum + r.totalHours);
    final formattedTotal =
        '${totalHours.toInt().toString().padLeft(2, '0')}:${((totalHours - totalHours.toInt()) * 60).round().toString().padLeft(2, '0')} ساعة';

    return Column(
      children: [
        Expanded(
          child: TableWidget<DailyAttendanceEmployeeReport>(
            columns: _columns,
            header: _headers,
            items: data,
            onTapRow: (report) =>
                RawFingerprintDetailDialog.show(context, report),
            builder: (context, report, index) {
              final st = report.status;
              return [
                Text('${index + 1}', style: TextStyle(fontSize: 14)),
                Text(
                  report.employeeName,
                  style: TextStyle(
                    fontSize: 14,
                    color: report.punchCount == 0 ? Theme.of(context).colorScheme.error : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${report.shiftStartTime == null ? AppLocalizations.of(context)!.dash : 'من ${formatTime(toTime(report.shiftStartTime!))}'}  ${report.shiftEndTime == null ? AppLocalizations.of(context)!.dash : 'إلى ${formatTime(toTime(report.shiftEndTime!))}'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: .bold,
                    color: report.shiftName == null ? Theme.of(context).colorScheme.error : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text(
                      getDayName(report.date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                      formatDate(report.date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                _buildStatusBadge(st),
                Text(
                  report.formattedFirstPunchTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: report.firstPunchDateTime == null
                        ? Theme.of(context).colorScheme.error
                        : (st?.color ?? Theme.of(context).colorScheme.onSurface),
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.ltr,
                ),
                Text(
                  report.punchCount <= 1
                      ? AppLocalizations.of(context)!.dash
                      : report.formattedLastPunchTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: report.punchCount <= 1
                        ? Theme.of(context).colorScheme.outline
                        : (report.lastPunchStatus?.color ??
                              Theme.of(context).colorScheme.onSurface),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  report.punchCount <= 1
                      ? '00:00 ساعة'
                      : report.formattedTotalHours,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: report.punchCount > 1 && report.totalHours > 0
                        ? Theme.of(context).colorScheme.success
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                Text(
                  report.punchCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ];
            },
          ),
        ),
        SizedBox(height: 8),
        _buildFooter(attendanceDays, formattedTotal),
      ],
    );
  }

  Widget _buildFooter(int attendanceDays, String totalHours) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.summarize_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.totalAttendanceDays(attendanceDays),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 24),
          Icon(Icons.access_time_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.totalHoursSummary(totalHours),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AttendanceReviewStatus? status) {
    if (status == null) {
      return Text(
        AppLocalizations.of(context)!.dash,
        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: status.color,
        ),
      ),
    );
  }
}
