import 'dart:async';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/features/system/presentation/widgets/biometric_device_connection_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:fingerprint_frontend/core/device/biometric_device_controller.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/biometric_devices_repository.dart';
import 'package:fingerprint_frontend/core/repositories/interfaces/attendance_logs_repository.dart';
import 'device_properties_tab.dart';
import 'device_users_tab.dart';
import 'device_templates_tab.dart';
import 'device_attendance_tab.dart';
import 'device_live_capture_tab.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DeviceprintView extends StatefulWidget {
  final BiometricDeviceModel device;
  const DeviceprintView({super.key, required this.device});

  @override
  State<DeviceprintView> createState() => _DeviceprintViewState();
}

class _DeviceprintViewState extends State<DeviceprintView>
    with SingleTickerProviderStateMixin {
  late final BiometricDeviceController _controller;
  late final BiometricDevicesRepository _biometricDevicesRepository;
  late final AttendanceLogsRepository _attendanceLogsRepository;
  late TabController _tabController;

  StreamSubscription<DeviceControllerState>? _stateSub;
  StreamSubscription<LiveAttendanceEvent>? _liveSub;
  StreamSubscription<String>? _errorSub;

  DeviceControllerState _deviceState = DeviceControllerState.idle;

  String? _lastSyncTime;
  DateTime? _lastRequestDate;

  final List<LiveAttendanceEvent> _liveLogs = [];

  final _propertiesTabKey = GlobalKey<DevicePropertiesTabState>();
  final _usersTabKey = GlobalKey<DeviceUsersTabState>();
  final _templatesTabKey = GlobalKey<DeviceTemplatesTabState>();
  final _attendanceTabKey = GlobalKey<DeviceAttendanceTabState>();

  @override
  void initState() {
    super.initState();
    _lastSyncTime = widget.device.lastSync?.toString();
    _lastRequestDate = widget.device.lastRequestDate;
    _tabController = TabController(length: 5, vsync: this);
    _biometricDevicesRepository = GetIt.instance<BiometricDevicesRepository>();
    _attendanceLogsRepository = GetIt.instance<AttendanceLogsRepository>();
    _controller = GetIt.instance<BiometricDeviceController>(
      param1: widget.device,
    );

    _tabController.addListener(_onTabChanged);

    _stateSub = _controller.stateStream.listen((state) {
      if (mounted) setState(() => _deviceState = state);
    });

    _errorSub = _controller.errorStream.listen((msg) {
      if (mounted) _showSnack(msg, color: Theme.of(context).colorScheme.error);
    });

    _liveSub = _controller.liveStream.listen((event) {
      if (mounted) setState(() => _liveLogs.insert(0, event));
    });

    _connect();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _isConnected) {
      switch (_tabController.index) {
        case 1:
          _usersTabKey.currentState?.fetchUsers();
        case 2:
          _templatesTabKey.currentState?.fetchTemplates();
        case 3:
      }
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _liveSub?.cancel();
    _errorSub?.cancel();
    _controller.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  bool get _isConnected => _deviceState == DeviceControllerState.connected;
  bool get _isConnecting => _deviceState == DeviceControllerState.connecting;
  bool get _isExecuting => _deviceState == DeviceControllerState.executing;
  bool get _isListening => _controller.isLiveCaptureActive;

  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    final ctx = _key.currentContext ?? context;
    final colors = Theme.of(ctx).colorScheme;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Stack(
          alignment: .topLeft,
          children: [
            SelectableText(message),
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainer,
                foregroundColor: colors.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: .all(Radius.circular(8.0)),
                ),
              ),
              icon: Icon(Icons.copy_all_outlined),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
              },
            ),
          ],
        ),
        backgroundColor: color ?? Theme.of(context).colorScheme.success,
      ),
    );
  }

  Future<void> _connect() async {
    final success = await _controller.connect();
    if (mounted && success) {
      _showSnack(AppLocalizations.of(context)!.deviceConnectedSuccess);
    }
  }

  void _startLiveCapture() {
    _controller.startLiveCapture();
    if (mounted) setState(() {});
  }

  void _stopLiveCapture() {
    _controller.stopLiveCapture();
    if (mounted) setState(() {});
  }

  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      key: _key,
      insetPadding: EdgeInsets.all(24),
      child: SizedBox(
        width: 1000,
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.close, color: colors.onPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  SizedBox(
                    width: 200,
                    child: BiometricDeviceConnectionHeaderWidget(
                      isConnected: _isConnected,
                    ),
                  ),
                ],
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withAlpha(180),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey(_isConnected),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isConnected
                              ? Theme.of(context).colorScheme.success
                              : Theme.of(context).colorScheme.error,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isConnected
                                          ? Theme.of(context).colorScheme.success
                                          : Theme.of(context).colorScheme.error)
                                      .withAlpha(80),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.manageDevice,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                          Text(
                            widget.device.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  tabAlignment: TabAlignment.fill,
                  indicatorColor: colors.onPrimary,
                  labelColor: colors.onPrimary,
                  unselectedLabelColor: colors.onPrimary.withAlpha(150),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.info_outline),
                      text: AppLocalizations.of(context)!.propertiesTab,
                    ),
                    Tab(icon: Icon(Icons.people_outline), text: AppLocalizations.of(context)!.employeesTab),
                    Tab(icon: Icon(Icons.fingerprint), text: AppLocalizations.of(context)!.fingerprintsTab),
                    Tab(icon: Icon(Icons.history), text: AppLocalizations.of(context)!.attendanceTab),
                    Tab(icon: Icon(Icons.sensors), text: AppLocalizations.of(context)!.liveCaptureTab),
                  ],
                ),
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: TabBarView(
                  key: ValueKey(_tabController.index),
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    DevicePropertiesTab(
                      key: _propertiesTabKey,
                      device: widget.device,
                      controller: _controller,
                      biometricDevicesRepository: _biometricDevicesRepository,
                      attendanceLogsRepository: _attendanceLogsRepository,
                      isConnected: _isConnected,
                      isConnecting: _isConnecting,
                      isExecuting: _isExecuting,
                      lastSyncTime: _lastSyncTime,
                      lastRequestDate: _lastRequestDate,
                      onShowSnack: _showSnack,
                      onLastSyncTimeChanged: (value) {
                        if (mounted) setState(() => _lastSyncTime = value);
                      },
                    ),
                    DeviceUsersTab(
                      key: _usersTabKey,
                      device: widget.device,
                      biometricDevicesRepository: _biometricDevicesRepository,
                      isConnected: _isConnected,
                      onShowSnack: _showSnack,
                    ),
                    DeviceTemplatesTab(
                      key: _templatesTabKey,
                      device: widget.device,
                      biometricDevicesRepository: _biometricDevicesRepository,
                      isConnected: _isConnected,
                      onShowSnack: _showSnack,
                    ),
                    DeviceAttendanceTab(
                      key: _attendanceTabKey,
                      device: widget.device,
                      attendanceLogsRepository: _attendanceLogsRepository,
                      isConnected: _isConnected,
                      onShowSnack: _showSnack,
                    ),
                    DeviceLiveCaptureTab(
                      controller: _controller,
                      isConnected: _isConnected,
                      isListening: _isListening,
                      liveLogs: _liveLogs,
                      onStart: _startLiveCapture,
                      onStop: _stopLiveCapture,
                      onShowSnack: _showSnack,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
