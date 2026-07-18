import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DeviceActivityReportView extends StatefulWidget {
  final int deviceId;

  const DeviceActivityReportView({super.key, required this.deviceId});

  @override
  State<DeviceActivityReportView> createState() =>
      _DeviceActivityReportViewState();
}

class _DeviceActivityReportViewState extends State<DeviceActivityReportView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deviceActivityReport),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.comingSoon,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.featureUnderDevelopment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
