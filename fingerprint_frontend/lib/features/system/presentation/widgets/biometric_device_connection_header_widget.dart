import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class BiometricDeviceConnectionHeaderWidget extends StatelessWidget {
  final bool isConnected;
  const BiometricDeviceConnectionHeaderWidget({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),

      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsetsDirectional.only(end: 16),
      decoration: BoxDecoration(
        color: isConnected
            ? Theme.of(context).colorScheme.success.withAlpha(50)
            : Theme.of(context).colorScheme.error.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              key: ValueKey(isConnected),
              color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(width: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isConnected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.error,
            ),
            child: Text(isConnected ? AppLocalizations.of(context)!.connected : AppLocalizations.of(context)!.disconnected),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
