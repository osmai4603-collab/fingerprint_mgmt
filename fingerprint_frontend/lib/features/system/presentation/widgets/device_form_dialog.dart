import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';

class DeviceFormDialog extends StatefulWidget {
  final BiometricDeviceModel? device;

  const DeviceFormDialog({super.key, this.device});

  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late BiometricDeviceType? _deviceType;

  bool get _isEditing => widget.device != null;

  static const _deviceTypes = [
    BiometricDeviceType.zkteco,
    BiometricDeviceType.real,
    BiometricDeviceType.hikvision,
    BiometricDeviceType.generic,
  ];

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final List<Animation<Offset>> _slideUps;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device?.name ?? '');
    _ipController = TextEditingController(text: widget.device?.ipAddress ?? '');
    _portController = TextEditingController(
      text: widget.device?.port.toString() ?? '4370',
    );
    _deviceType = widget.device?.deviceType ?? BiometricDeviceType.zkteco;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideUps = List.generate(4, (i) {
      final start = (i * 0.1).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      final device = BiometricDeviceEntity(
        id: 0,
        name: _nameController.text.trim(),
        ipAddress: _ipController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 0,
        deviceType: _deviceType!,
      );
      Navigator.of(context).pop(device);
    }
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return SlideTransition(
      position: _slideUps[index],
      child: FadeTransition(opacity: _fadeIn, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(180)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        _isEditing ? Icons.edit_rounded : Icons.devices_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _isEditing ? 'تعديل جهاز' : 'إضافة جهاز جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _isEditing
                          ? 'تعديل بيانات الجهاز البيومتري'
                          : 'أدخل بيانات الجهاز البيومتري',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAnimatedField(
                        0,
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.deviceName,
                            prefixIcon: Align(
                              child: Icon(Icons.devices_rounded),
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? AppLocalizations.of(context)!.deviceNameRequired
                              : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        1,
                        TextFormField(
                          controller: _ipController,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.ipAddress,
                            prefixIcon: Align(child: Icon(Icons.location_pin)),
                          ),
                          validator: _validateIpAddress,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        2,
                        TextFormField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.ltr,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.port,
                            prefixIcon: Align(
                              child: Icon(Icons.private_connectivity),
                            ),
                          ),
                          validator: _validatePort,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildAnimatedField(
                        3,
                        DropdownButtonFormField<BiometricDeviceType>(
                          initialValue: _deviceType,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.deviceType,
                            prefixIcon: Align(
                              child: Icon(Icons.device_hub_rounded),
                            ),
                          ),
                          items: _deviceTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _deviceType = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _fadeIn,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: Icon(
                          _isEditing ? Icons.save_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                        label: Text(_isEditing ? 'حفظ' : 'إضافة'),
                        onPressed: _onSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePort(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'يرجى إدخال رقم المنفذ';
    }
    final port = int.tryParse(v.trim());
    if (port == null || port < 1 || port > 65535) {
      return 'رقم المنفذ غير صالح (1-65535)';
    }
    return null;
  }

  String? _validateIpAddress(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'يرجى إدخال عنوان IP';
    }
    final ip = v.trim();
    final ipv4 = RegExp(
      r'^(?:(?:25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(?:25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );
    final ipv6 = RegExp(r'^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    if (ipv4.hasMatch(ip) || ipv6.hasMatch(ip)) return null;
    return 'عنوان IP غير صالح (IPv4/IPv6)';
  }
}
