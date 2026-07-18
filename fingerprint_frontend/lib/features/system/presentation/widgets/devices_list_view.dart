import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';
import 'package:fingerprint_frontend/core/widgets/dialogs/confirm_delete_dialog.dart';
import 'package:fingerprint_frontend/core/widgets/icon_button_widget.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import 'package:fingerprint_frontend/features/system/presentation/widgets/device_print_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../bloc/devices_bloc.dart';
import '../bloc/devices_event.dart';
import '../bloc/devices_state.dart';
import 'device_form_dialog.dart';
import '../../../../core/widgets/table_widget.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DevicesListView extends StatefulWidget {
  const DevicesListView({super.key});

  @override
  State<DevicesListView> createState() => _DevicesListViewState();
}

class _DevicesListViewState extends State<DevicesListView> {
  @override
  void initState() {
    super.initState();
    context.read<DevicesBloc>().add(const LoadDevicesEvent());
  }

  void _showAddDialog() async {
    final result = await showDialog<BiometricDeviceEntity>(
      context: context,
      builder: (_) => const DeviceFormDialog(),
    );
    if (result != null && mounted) {
      context.read<DevicesBloc>().add(CreateDeviceEvent(device: result));
    }
  }

  void _showEditDialog(BiometricDeviceModel device) async {
    final result = await showDialog<BiometricDeviceEntity>(
      context: context,
      builder: (_) => DeviceFormDialog(device: device),
    );
    if (result != null && mounted) {
      context.read<DevicesBloc>().add(UpdateDeviceEvent(result));
    }
  }

  void _confirmDelete(BiometricDeviceModel device) async {
    final context = this.context;
    final result =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => ConfirmDeleteDialog(
            title: AppLocalizations.of(context)!.confirmDelete,
            content: AppLocalizations.of(context)!.confirmDeleteDevice(device.name),
          ),
        ) ??
        false;
    if (result && context.mounted) {
      context.read<DevicesBloc>().add(DeleteDeviceEvent(id: device.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DevicesBloc, DevicesState>(
      listener: (context, state) {
        if (state is DevicesOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.success,
            ),
          );
        }
        if (state is DevicesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: SelectableText(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final devices = state is DevicesLoaded
            ? state.devices
            : <BiometricDeviceModel>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                spacing: 10,
                children: [
                  Text(
                    AppLocalizations.of(context)!.deviceManagement,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButtonWidget(
                    icon: Icons.refresh_rounded,
                    iconSize: 20,
                    tooltip: AppLocalizations.of(context)!.reload,
                    onPressed: () => context.read<DevicesBloc>().add(
                      const LoadDevicesEvent(),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.addDevice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildDevicesTable(
                state,
                devices,
                AppLocalizations.of(context),
              ),
            ),
          ],
        );
      },
    );
  }

  final _columns = const {
    0: FlexTableWidgetColumnWidth(1, alignment: .centerRight, padding: .all(8)),
    1: FlexTableWidgetColumnWidth(3, alignment: .centerStart),
    2: FlexTableWidgetColumnWidth(3),
    3: FlexTableWidgetColumnWidth(2),
    4: FlexTableWidgetColumnWidth(3),
    5: FlexTableWidgetColumnWidth(2, alignment: .center),
    6: FlexTableWidgetColumnWidth(3.2),
    7: FixedTableWidgetColumnWidth(120, alignment: .center),
  };

  List<String> _headers(BuildContext context) => [
    AppLocalizations.of(context)!.tableNo,
    AppLocalizations.of(context)!.deviceName,
    AppLocalizations.of(context)!.ipAddress,
    AppLocalizations.of(context)!.port,
    AppLocalizations.of(context)!.deviceType,
    AppLocalizations.of(context)!.status,
    AppLocalizations.of(context)!.lastSync,
    AppLocalizations.of(context)!.actions,
  ];

  Widget _buildDevicesTable(
    DevicesState state,
    List<BiometricDeviceModel> devices,
    AppLocalizations? localization,
  ) {
    if (state is DevicesLoading && devices.isEmpty) {
      return Center(child: ShimmerLoading.table(rows: 20, columns: 8));
    }
    if (devices.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noDevices));
    }

    final style = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: .bold);

    return TableWidget<BiometricDeviceModel>(
      columns: _columns,
      header: _headers(context),
      items: devices,
      minWidth: 1120,
      builder: (context, device, index) {
        return [
          Text('${index + 1}', style: style),
          Text(device.name, style: style),
          Text(device.ipAddress, style: style),
          Text('${device.port}', style: style),
          Text(device.deviceType.value, style: style),
          Text(
            device.isOnline ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnected,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: device.isOnline
                  ? Theme.of(context).colorScheme.success
                  : Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            device.lastRequestDate != null
                ? formatDateTime(device.lastRequestDate!)
                : AppLocalizations.of(context)!.notSynced,
            style: style?.copyWith(fontWeight: .w500),
          ),
          _buildActionButtons(device),
        ];
      },
      onTapRow: (device) {
        showDialog(
          context: context,
          builder: (_) => DeviceprintView(device: device),
        );
      },
    );
  }

  Widget _buildActionButtons(BiometricDeviceModel device) {
    return Row(
      mainAxisAlignment: .center,
      spacing: 10,
      children: [
        IconButtonWidget(
          icon: (Icons.edit_outlined),
          tooltip: AppLocalizations.of(context)!.editUser,
          onPressed: () => _showEditDialog(device),
        ),
        IconButtonWidget(
          icon: Icons.delete_outline,
          iconColor: Theme.of(context).colorScheme.error,
          tooltip: AppLocalizations.of(context)!.deleteUser,
          onPressed: () => _confirmDelete(device),
        ),
      ],
    );
  }
}
