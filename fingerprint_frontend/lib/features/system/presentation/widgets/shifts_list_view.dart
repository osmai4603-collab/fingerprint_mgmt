import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/widgets/icon_button_widget.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../bloc/shifts_bloc.dart';
import '../bloc/shifts_event.dart';
import '../bloc/shifts_state.dart';
import 'shift_form_dialog.dart';
import '../../../../core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class ShiftsListView extends StatefulWidget {
  const ShiftsListView({super.key});

  @override
  State<ShiftsListView> createState() => _ShiftsListViewState();
}

class _ShiftsListViewState extends State<ShiftsListView> {
  @override
  void initState() {
    super.initState();
    context.read<ShiftsBloc>().add(const LoadShiftsEvent());
  }

  void _onAddNewShift() async {
    final bloc = context.read<ShiftsBloc>();
    final result =
        await showDialog<bool>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ShiftsBloc>(),
            child: const ShiftFormDialog(),
          ),
        ) ??
        false;
    if (context.mounted && result) {
      bloc.add(const LoadShiftsEvent());
    }
  }

  void _showEditDialog(ShiftEntity shift) async {
    final bloc = context.read<ShiftsBloc>();
    final result =
        await showDialog<bool>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ShiftsBloc>(),
            child: ShiftFormDialog(shift: shift),
          ),
        ) ??
        false;
    if (context.mounted && result) {
      bloc.add(const LoadShiftsEvent());
    }
  }

  void _confirmDelete(ShiftEntity shift) async {
    final bloc = context.read<ShiftsBloc>();
    final result =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => ConfirmDeleteDialog(
            title: AppLocalizations.of(context)!.confirmDelete,
            content: AppLocalizations.of(
              context,
            )!.confirmDeleteShift(shift.name),
          ),
        ) ??
        false;
    if (result && context.mounted) {
      bloc.add(DeleteShiftEvent(id: shift.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShiftsBloc, ShiftsState>(
      listener: (context, state) {
        if (state is ShiftsOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
        if (state is ShiftsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final shifts = state is ShiftsLoaded ? state.shifts : <ShiftEntity>[];

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.shiftManagement,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh_rounded),
                    tooltip: AppLocalizations.of(context)!.reload,
                    onPressed: () =>
                        context.read<ShiftsBloc>().add(const LoadShiftsEvent()),
                  ),
                  ElevatedButton.icon(
                    onPressed: _onAddNewShift,
                    icon: Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addShift),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(child: _buildShiftsTable(state, shifts)),
            ],
          ),
        );
      },
    );
  }

  final _columns = const {
    0: FlexTableWidgetColumnWidth(
      1,
      alignment: .centerRight,
      padding: .all(8.0),
    ),
    1: FlexTableWidgetColumnWidth(3, alignment: .centerStart),
    2: FlexTableWidgetColumnWidth(2, alignment: .center),
    3: FlexTableWidgetColumnWidth(2, alignment: .center),
    4: FlexTableWidgetColumnWidth(2, alignment: .center),
    5: FlexTableWidgetColumnWidth(2, alignment: .center),
    6: FlexTableWidgetColumnWidth(2, alignment: .center),
    7: FlexTableWidgetColumnWidth(3, alignment: .center),
  };

  List<String> _headers(BuildContext context) => [
    AppLocalizations.of(context)!.tableNo,
    AppLocalizations.of(context)!.name,
    AppLocalizations.of(context)!.startTime,
    AppLocalizations.of(context)!.endTime,
    AppLocalizations.of(context)!.nightShift,
    AppLocalizations.of(context)!.overtimeShift,
    AppLocalizations.of(context)!.holiday,
    AppLocalizations.of(context)!.actions,
  ];

  Widget _buildShiftsTable(ShiftsState state, List<ShiftEntity> shifts) {
    if (state is ShiftsLoading && shifts.isEmpty) {
      return Center(child: ShimmerLoading.table(rows: 20, columns: 8));
    }
    if (shifts.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noShifts));
    }

    return TableWidget<ShiftEntity>(
      columns: _columns,
      header: _headers(context),
      items: shifts,
      minWidth: 1000,
      builder: (context, shift, index) {
        return [
          Text(shift.id.toString(), style: TextStyle(fontSize: 14)),
          Text(shift.name, style: TextStyle(fontSize: 14, fontWeight: .bold)),
          Text(
            formatTime(shift.startTime),
            style: TextStyle(fontSize: 14, fontWeight: .bold),
          ),
          Text(
            formatTime(shift.endTime),
            style: TextStyle(fontSize: 14, fontWeight: .bold),
          ),
          Icon(
            shift.isNightShift ? Icons.check_circle : Icons.cancel,
            color: shift.isNightShift ? Colors.green : Colors.grey,
            size: 20,
          ),
          Icon(
            shift.acceptOvertime ? Icons.check_circle : Icons.cancel,
            color: shift.acceptOvertime ? Colors.green : Colors.grey,
            size: 20,
          ),
          Text(
            shift.weekendDays
                    ?.map((d) => getDayNameByNumber(d.value))
                    .join(' - ') ??
                '-',
            style: TextStyle(fontSize: 14),
          ),
          _buildActionButtons(shift),
        ];
      },
    );
  }

  Widget _buildActionButtons(ShiftEntity shift) {
    return Row(
      spacing: 10,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButtonWidget(
          onPressed: () => _showEditDialog(shift),
          icon: (Icons.edit_outlined),
          tooltip: AppLocalizations.of(context)!.editUser,
        ),
        IconButtonWidget(
          onPressed: () => _confirmDelete(shift),
          icon: Icons.delete_outline,
          tooltip: AppLocalizations.of(context)!.delete,
          iconColor: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}
