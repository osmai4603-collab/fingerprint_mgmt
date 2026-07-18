import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/services/date_time_format.dart';
import '../../../../core/widgets/table_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/shared/shared_core.dart';
import '../../../employees/presentation/bloc/employees_bloc.dart';
import '../bloc/reports_bloc.dart';
import 'detailed_report_detail_dialog.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class ReportsDashboardView extends StatefulWidget {
  const ReportsDashboardView({super.key});

  @override
  State<ReportsDashboardView> createState() => _ReportsDashboardViewState();
}

class _ReportsDashboardViewState extends State<ReportsDashboardView> {
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedEmployeeId;
  ReportType _selectedReportType = ReportType.fingerprint;

  @override
  void initState() {
    super.initState();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
  }

  void _loadReport() {
    if (_fromDate == null || _toDate == null) return;
    context.read<ReportsBloc>().add(
      LoadReportEvent(
        reportType: _selectedReportType,
        from: _fromDate!,
        to: _toDate!,
        employeeId: _selectedEmployeeId,
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isFrom) {
          _fromDate = date;
        } else {
          _toDate = date;
        }
      });
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          _buildFilterCard(theme),
          Expanded(child: _buildReportContent()),
        ],
      ),
    );
  }

  Widget _buildFilterCard(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildExportButton(
                    context: context,
                    icon: Icons.table_chart_outlined,
                    label: AppLocalizations.of(context)!.exportExcel,
                    onPressed: _exportExcel,
                  ),
                  SizedBox(height: 8),
                  _buildExportButton(
                    context: context,
                    icon: Icons.picture_as_pdf_outlined,
                    label: AppLocalizations.of(context)!.exportPdf,
                    onPressed: _exportPdf,
                  ),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.reports,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: TextFormField(
                              textDirection: TextDirection.ltr,
                              readOnly: true,
                              onTap: () => _pickDate(isFrom: true),
                              controller: TextEditingController(
                                text: _fromDate != null
                                    ? formatDate(_fromDate!)
                                    : '',
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  context,
                                )!.fromDate,
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: TextFormField(
                              textDirection: TextDirection.ltr,
                              readOnly: true,
                              onTap: () => _pickDate(isFrom: false),
                              controller: TextEditingController(
                                text: _toDate != null
                                    ? formatDate(_toDate!)
                                    : '',
                              ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.toDate,
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                        BlocBuilder<EmployeesBloc, EmployeesState>(
                          builder: (context, state) {
                            if (state is EmployeesLoaded) {
                              return SizedBox(
                                width: 220,
                                child: DropdownButtonFormField<int?>(
                                  initialValue: _selectedEmployeeId,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      context,
                                    )!.employee,
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.allEmployees,
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
                                    _loadReport();
                                  },
                                ),
                              );
                            }
                            return SizedBox(width: 220);
                          },
                        ),
                        FilledButton.icon(
                          onPressed: _loadReport,
                          icon: Icon(Icons.search, size: 18),
                          label: Text(AppLocalizations.of(context)!.search),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildReportTypeSelector(Theme.of(context).colorScheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 130,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _exportExcel() async {
    final state = context.read<ReportsBloc>().state;
    if (state is! ReportsLoaded || state.data.isEmpty) return;

    final rows = switch (state.reportType) {
      ReportType.fingerprint => _fingerprintCsvRows(
        state.data.cast<EmployeeFingerprintReport>(),
      ),
      ReportType.summary => _summaryCsvRows(
        state.data.cast<AttendanceSummaryReport>(),
      ),
      ReportType.detailed => _detailedCsvRows(
        state.data.cast<DetailedDailyReport>(),
      ),
      ReportType.attendanceOnly => _detailedCsvRows(
        state.data.cast<DetailedDailyReport>(),
      ),
      ReportType.absenceOnly => _detailedCsvRows(
        state.data.cast<DetailedDailyReport>(),
      ),
      ReportType.late => _detailedCsvRows(
        state.data.cast<DetailedDailyReport>(),
      ),
      ReportType.absenceWithDeductions => _detailedCsvRows(
        state.data.cast<DetailedDailyReport>(),
      ),
    };

    final csvData = const ListToCsvConverter().convert(rows);
    final bom = '\uFEFF$csvData';

    final path = await FilePicker.platform.saveFile(
      fileName: 'report.csv',
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (path != null) {
      await File(path).writeAsString(bom);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reportExported)),
        );
      }
    }
  }

  List<List<String>> _fingerprintCsvRows(List<EmployeeFingerprintReport> data) {
    const headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'بصمة 1',
      'بصمة 2',
      'بصمة 3',
      'بصمة 4',
      'بصمة 5',
      'بصمة 6',
    ];
    final rows = data.asMap().entries.map((e) {
      final r = e.value;
      return [
        '${e.key + 1}',
        r.employeeName,
        formatDate(r.date),
        fmtDateTime(r.punch1),
        fmtDateTime(r.punch2),
        fmtDateTime(r.punch3),
        fmtDateTime(r.punch4),
        fmtDateTime(r.punch5),
        fmtDateTime(r.punch6),
      ];
    }).toList();
    return [headers, ...rows];
  }

  List<List<String>> _summaryCsvRows(List<AttendanceSummaryReport> data) {
    const headers = [
      'No.',
      'اسم الموظف',
      'ساعات العمل',
      'ساعات الإضافي',
      'ساعات الغياب',
      'مبلغ الخصم',
    ];
    final rows = data.asMap().entries.map((e) {
      final r = e.value;
      return [
        '${e.key + 1}',
        r.employeeName,
        formatHours(r.workHours),
        formatHours(r.overtimeHours),
        formatHours(r.absenceHours),
        r.deductionAmount.toStringAsFixed(2),
      ];
    }).toList();
    return [headers, ...rows];
  }

  List<List<String>> _detailedCsvRows(List<DetailedDailyReport> data) {
    const headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'الوردية',
      'وقت الحضور',
      'وقت الانصراف',
      'ساعات العمل',
      'ساعات الإضافي',
      'حالة الدوام',
      'ساعات الغياب',
    ];
    final rows = data.asMap().entries.map((e) {
      final r = e.value;
      return [
        '${e.key + 1}',
        r.employeeName,
        r.date != null
            ? formatDate(r.date!)
            : AppLocalizations.of(context)!.dash,
        r.shiftName ?? AppLocalizations.of(context)!.dash,
        fmtTime(r.attendanceTime),
        fmtTime(r.departureTime),
        formatHours(r.workHours),
        formatHours(r.overtimeHours),
        r.attendanceStatus ?? AppLocalizations.of(context)!.dash,
        formatHours(r.absenceHours),
      ];
    }).toList();
    return [headers, ...rows];
  }

  Future<void> _exportPdf() async {
    final state = context.read<ReportsBloc>().state;
    if (state is! ReportsLoaded || state.data.isEmpty) return;

    final fontData = await rootBundle.load(
      'fonts/Noto_Naskh_Arabic/NotoNaskhArabic-Regular.ttf',
    );
    final arabicFont = pw.Font.ttf(fontData);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(state.label, style: pw.TextStyle(font: arabicFont)),
          ),
          pw.SizedBox(height: 10),
          switch (state.reportType) {
            ReportType.fingerprint => _buildFingerprintPdfTable(
              state.data.cast<EmployeeFingerprintReport>(),
              arabicFont,
            ),
            ReportType.summary => _buildSummaryPdfTable(
              state.data.cast<AttendanceSummaryReport>(),
              arabicFont,
            ),
            ReportType.detailed => _buildDetailedPdfTable(
              state.data.cast<DetailedDailyReport>(),
              arabicFont,
            ),
            ReportType.attendanceOnly => _buildDetailedPdfTable(
              state.data.cast<DetailedDailyReport>(),
              arabicFont,
            ),
            ReportType.absenceOnly => _buildDetailedPdfTable(
              state.data.cast<DetailedDailyReport>(),
              arabicFont,
            ),
            ReportType.late => _buildDetailedPdfTable(
              state.data.cast<DetailedDailyReport>(),
              arabicFont,
            ),
            ReportType.absenceWithDeductions => _buildDetailedPdfTable(
              state.data.cast<DetailedDailyReport>(),
              arabicFont,
            ),
          },
        ],
      ),
    );

    final bytes = await pdf.save();
    final path = await FilePicker.platform.saveFile(
      fileName: 'report.pdf',
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (path != null) {
      await File(path).writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reportExported)),
        );
      }
    }
  }

  pw.Widget _buildFingerprintPdfTable(
    List<EmployeeFingerprintReport> data,
    pw.Font arabicFont,
  ) {
    const headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'بصمة 1',
      'بصمة 2',
      'بصمة 3',
      'بصمة 4',
      'بصمة 5',
      'بصمة 6',
    ];
    final rows = _fingerprintCsvRows(data).skip(1).toList();
    return _buildPdfTable(
      headers: headers,
      rows: rows,
      arabicFont: arabicFont,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(70),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(70),
        5: const pw.FixedColumnWidth(70),
        6: const pw.FixedColumnWidth(70),
        7: const pw.FixedColumnWidth(70),
        8: const pw.FixedColumnWidth(70),
      },
    );
  }

  pw.Widget _buildSummaryPdfTable(
    List<AttendanceSummaryReport> data,
    pw.Font arabicFont,
  ) {
    const headers = [
      'No.',
      'اسم الموظف',
      'ساعات العمل',
      'ساعات الإضافي',
      'ساعات الغياب',
      'مبلغ الخصم',
    ];
    final rows = _summaryCsvRows(data).skip(1).toList();
    return _buildPdfTable(
      headers: headers,
      rows: rows,
      arabicFont: arabicFont,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(80),
        4: const pw.FixedColumnWidth(80),
        5: const pw.FixedColumnWidth(80),
      },
    );
  }

  pw.Widget _buildDetailedPdfTable(
    List<DetailedDailyReport> data,
    pw.Font arabicFont,
  ) {
    const headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'الوردية',
      'وقت الحضور',
      'وقت الانصراف',
      'ساعات العمل',
      'ساعات الإضافي',
      'حالة الدوام',
      'ساعات الغياب',
    ];
    final rows = _detailedCsvRows(data).skip(1).toList();
    final numericCols = {0, 6, 7, 9};
    return _buildPdfTable(
      headers: headers,
      rows: rows,
      arabicFont: arabicFont,
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(65),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FixedColumnWidth(65),
        5: const pw.FixedColumnWidth(65),
        6: const pw.FixedColumnWidth(55),
        7: const pw.FixedColumnWidth(55),
        8: const pw.FixedColumnWidth(60),
        9: const pw.FixedColumnWidth(55),
      },
      numericCols: numericCols,
    );
  }

  pw.Widget _buildPdfTable({
    required List<String> headers,
    required List<List<String>> rows,
    required pw.Font arabicFont,
    required Map<int, pw.FixedColumnWidth> columnWidths,
    Set<int> numericCols = const {},
  }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFE0E0E0)),
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
    );
  }

  Widget _buildReportTypeSelector(ColorScheme theme) {
    final types = ReportType.values;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: types.map((type) {
        final isSelected = _selectedReportType == type;
        return ChoiceChip(
          label: Text(
            type.label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? theme.onSecondary : null,
            ),
          ),
          selected: isSelected,
          selectedColor: theme.secondary,
          onSelected: (_) {
            setState(() => _selectedReportType = type);
            _loadReport();
          },
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        );
      }).toList(),
    );
  }

  Widget _buildReportContent() {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return ShimmerLoading.table(rows: 50, columns: 9);
        }
        if (state is ReportsError) {
          return Center(
            child: Text(state.message, style: TextStyle(color: Colors.red)),
          );
        }
        if (state is ReportsLoaded) {
          if (state.data.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noRecordsFound),
            );
          }
          return _buildTable(state);
        }
        return Center(
          child: Text(AppLocalizations.of(context)!.selectReportType),
        );
      },
    );
  }

  Widget _buildTable(ReportsLoaded state) {
    switch (state.reportType) {
      case ReportType.fingerprint:
        return _buildFingerprintTable(
          state.data.cast<EmployeeFingerprintReport>(),
        );
      case ReportType.summary:
        return _buildSummaryTable(state.data.cast<AttendanceSummaryReport>());
      case ReportType.detailed:
      case ReportType.attendanceOnly:
      case ReportType.absenceOnly:
      case ReportType.late:
      case ReportType.absenceWithDeductions:
        return _buildDetailedTable(state.data.cast<DetailedDailyReport>());
    }
  }

  String fmtDateTime(DateTime? dt) =>
      dt != null ? formatTime(dt) : AppLocalizations.of(context)!.dash;

  String fmtAmount(double a) =>
      AppLocalizations.of(context)!.currencyFormat(a.toStringAsFixed(2));

  String fmtTime(DateTime? dt) =>
      dt != null ? formatTime(dt) : AppLocalizations.of(context)!.dash;

  Color stateColor(String? status) {
    if (status == null) return Theme.of(context).colorScheme.outline;
    if (status.contains('غائب') || status.contains('غياب')) {
      return Theme.of(context).colorScheme.error;
    }
    if (status.contains('متأخر')) {
      return Theme.of(context).colorScheme.lateStatus;
    }
    if (status.contains('ممتاز') || status.contains('مقبول')) {
      return Theme.of(context).colorScheme.success;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  Widget _buildFingerprintTable(List<EmployeeFingerprintReport> data) {
    final columns = {
      0: FixedTableWidgetColumnWidth(40, alignment: Alignment.center),
      1: FlexTableWidgetColumnWidth(1, alignment: .centerStart),
      2: FixedTableWidgetColumnWidth(130, alignment: Alignment.center),
      3: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      4: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      5: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      6: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      7: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      8: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
    };
    final headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'بصمة 1',
      'بصمة 2',
      'بصمة 3',
      'بصمة 4',
      'بصمة 5',
      'بصمة 6',
    ];
    final style = TextTheme.of(context).bodySmall?.copyWith(fontWeight: .bold);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TableWidget<EmployeeFingerprintReport>(
        columns: columns,
        header: headers,
        items: data,
        minWidth: 1090,
        paintRowColorWhen: (_, index) => index % 2 == 0,
        rowColor: Theme.of(
          context,
        ).colorScheme.secondary.withValues(alpha: 0.075),
        builder: (context, item, index) => [
          Text('${index + 1}', style: style),
          Text(item.employeeName, style: style),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(formatDate(item.date), style: style),
              Text(getDayName(item.date), style: style),
            ],
          ),
          Text(
            fmtDateTime(item.punch1),
            style: style,
            textDirection: TextDirection.ltr,
          ),
          Text(
            fmtDateTime(item.punch2),
            style: style,
            textDirection: TextDirection.ltr,
          ),
          Text(
            fmtDateTime(item.punch3),
            style: style,
            textDirection: TextDirection.ltr,
          ),
          Text(
            fmtDateTime(item.punch4),
            style: style,
            textDirection: TextDirection.ltr,
          ),
          Text(
            fmtDateTime(item.punch5),
            style: style,
            textDirection: TextDirection.ltr,
          ),
          Text(
            fmtDateTime(item.punch6),
            style: style,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTable(List<AttendanceSummaryReport> data) {
    const columns = {
      0: FixedTableWidgetColumnWidth(50, alignment: Alignment.center),
      1: FlexTableWidgetColumnWidth(3, alignment: .centerStart),
      2: FixedTableWidgetColumnWidth(160, alignment: Alignment.center),
      3: FixedTableWidgetColumnWidth(160, alignment: Alignment.center),
      4: FixedTableWidgetColumnWidth(160, alignment: Alignment.center),
      5: FixedTableWidgetColumnWidth(160, alignment: Alignment.center),
    };
    const headers = [
      'No.',
      'اسم الموظف',
      'ساعات العمل',
      'ساعات الإضافي',
      'ساعات الغياب',
      'مبلغ الخصم',
    ];
    final baseStyle = TextTheme.of(
      context,
    ).bodySmall?.copyWith(fontWeight: FontWeight.bold);

    final double totalWork = data.fold(0, (sum, item) => sum + item.workHours);
    final double totalOvertime = data.fold(
      0,
      (sum, item) => sum + item.overtimeHours,
    );
    final double totalAbsence = data.fold(
      0,
      (sum, item) => sum + item.absenceHours,
    );
    final double totalDeduction = data.fold(
      0,
      (sum, item) => sum + item.deductionAmount,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TableWidget<AttendanceSummaryReport>(
        columns: columns,
        header: headers,
        items: data,
        minWidth: 900,
        paintRowColorWhen: (_, index) => index % 2 == 0,
        rowColor: Theme.of(
          context,
        ).colorScheme.secondary.withValues(alpha: 0.075),

        footerBuilder: (context) => [
          const SizedBox.shrink(),
          Text(
            'الإجمالي',
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            formatHours(totalWork),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            formatHours(totalOvertime),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            formatHours(totalAbsence),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            fmtAmount(totalDeduction),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
        builder: (context, item, index) => [
          Text('${index + 1}', style: baseStyle),
          Text(item.employeeName, style: baseStyle),
          Text(formatHours(item.workHours), style: baseStyle),
          Text(
            formatHours(item.overtimeHours),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.success,
            ),
          ),
          Text(
            formatHours(item.absenceHours),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Text(
            fmtAmount(item.deductionAmount),
            style: baseStyle?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTable(List<DetailedDailyReport> data) {
    const columns = {
      0: FixedTableWidgetColumnWidth(40, alignment: Alignment.center),
      1: FlexTableWidgetColumnWidth(3, alignment: .centerStart),
      2: FixedTableWidgetColumnWidth(140, alignment: Alignment.center),
      3: FixedTableWidgetColumnWidth(100, alignment: Alignment.center),
      4: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      5: FixedTableWidgetColumnWidth(120, alignment: Alignment.center),
      6: FixedTableWidgetColumnWidth(90, alignment: Alignment.center),
      7: FixedTableWidgetColumnWidth(90, alignment: Alignment.center),
      8: FixedTableWidgetColumnWidth(90, alignment: Alignment.center),
      9: FixedTableWidgetColumnWidth(90, alignment: Alignment.center),
    };
    const headers = [
      'No.',
      'اسم الموظف',
      'التاريخ',
      'الوردية',
      'وقت الحضور',
      'وقت الانصراف',
      'ساعات العمل',
      'ساعات الإضافي',
      'حالة الدوام',
      'ساعات الغياب',
    ];
    final baseStyle = TextTheme.of(
      context,
    ).bodySmall?.copyWith(fontWeight: FontWeight.bold);

    final double totalWork = data.fold(0, (sum, item) => sum + item.workHours);
    final double totalOvertime = data.fold(
      0,
      (sum, item) => sum + item.overtimeHours,
    );
    final double totalAbsence = data.fold(
      0,
      (sum, item) => sum + item.absenceHours,
    );

    return TableWidget<DetailedDailyReport>(
      columns: columns,
      header: headers,
      items: data,
      minWidth: 1040,
      paintRowColorWhen: (_, index) => index % 2 == 0,
      rowColor: Theme.of(
        context,
      ).colorScheme.secondary.withValues(alpha: 0.075),

      footerBuilder: (context) => [
        const SizedBox.shrink(),
        Text(
          'الإجمالي',
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        Text(
          formatHours(totalWork),
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          formatHours(totalOvertime),
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox.shrink(),
        Text(
          formatHours(totalAbsence),
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
      onTapRow: (item) => DetailedReportDetailDialog.show(context, item),
      builder: (context, item, index) => [
        Text('${index + 1}', style: baseStyle),
        Text(item.employeeName, style: baseStyle),
        item.date == null
            ? Text(AppLocalizations.of(context)!.dash)
            : Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(formatDate(item.date!), style: baseStyle),
                  Text(getDayName(item.date!), style: baseStyle),
                ],
              ),
        Text(
          item.shiftName ?? AppLocalizations.of(context)!.dash,
          style: baseStyle,
        ),
        Text(
          fmtTime(item.attendanceTime),
          style: baseStyle,
          textDirection: TextDirection.ltr,
        ),
        Text(
          fmtTime(item.departureTime),
          style: baseStyle,
          textDirection: TextDirection.ltr,
        ),
        Text(formatHours(item.workHours), style: baseStyle),
        Text(
          formatHours(item.overtimeHours),
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.success,
          ),
        ),
        Text(
          item.attendanceStatus ?? AppLocalizations.of(context)!.dash,
          style: baseStyle?.copyWith(color: stateColor(item.attendanceStatus)),
        ),
        Text(
          formatHours(item.absenceHours),
          style: baseStyle?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    );
  }
}
