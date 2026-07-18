import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:fingerprint_frontend/core/device/biometric_device_controller.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DeviceLiveCaptureTab extends StatelessWidget {
  final BiometricDeviceController controller;
  final bool isConnected;
  final bool isListening;
  final List<LiveAttendanceEvent> liveLogs;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final void Function(String message, {Color? color}) onShowSnack;

  const DeviceLiveCaptureTab({
    super.key,
    required this.controller,
    required this.isConnected,
    required this.isListening,
    required this.liveLogs,
    required this.onStart,
    required this.onStop,
    required this.onShowSnack,
  });

  String _formatDateTime(dynamic dt) {
    if (dt == null) return '---';
    final DateTime? dateTime = dt is DateTime
        ? dt
        : DateTime.tryParse(dt.toString());
    if (dateTime == null) return '---';
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'الاستماع المباشر للبصمات',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isListening
                      ? Theme.of(context).colorScheme.success.withAlpha(25)
                      : Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isListening
                            ? Theme.of(context).colorScheme.success
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      isListening ? 'نشط' : 'متوقف',
                      style: TextStyle(
                        fontSize: 12,
                        color: isListening
                            ? Theme.of(context).colorScheme.success
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (liveLogs.isNotEmpty) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${liveLogs.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (isListening)
                ElevatedButton.icon(
                  onPressed: onStop,
                  icon: Icon(Icons.stop, size: 18),
                  label: Text(AppLocalizations.of(context)!.stop),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: isConnected ? onStart : null,
                  icon: Icon(Icons.play_arrow, size: 18),
                  label: Text(AppLocalizations.of(context)!.startListening),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.success,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
            ],
          ),
          Divider(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: liveLogs.isEmpty
                  ? Center(
                      key: const ValueKey('empty'),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          isListening
                              ? AppLocalizations.of(context)!.waitingForFingerprints
                              : 'اضغط "بدء الاستماع" لاستقبال البصمات المباشرة',
                          key: ValueKey(isListening),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('list'),
                      itemCount: liveLogs.length,
                      separatorBuilder: (_, _) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        final log = liveLogs[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(
                            milliseconds: index == 0 ? 400 : 200,
                          ),
                          curve: Curves.easeOut,
                          builder: (_, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - opacity)),
                                child: child,
                              ),
                            );
                          },
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                              child: Text(
                                log.biometricId,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'الموظف: ${log.biometricId}',
                              style: TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              log.isCheckIn ? 'دخول' : 'خروج',
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              _formatDateTime(log.timestamp.toIso8601String()),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
