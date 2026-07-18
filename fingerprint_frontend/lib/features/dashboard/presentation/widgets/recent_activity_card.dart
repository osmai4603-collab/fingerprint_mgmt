import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import 'package:intl/intl.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class RecentActivityCard extends StatelessWidget {
  final List<AttendanceLogModel> logs;

  const RecentActivityCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary.withAlpha(25), Theme.of(context).colorScheme.primary.withAlpha(8)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.recentActivities,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (logs.isEmpty)
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text(AppLocalizations.of(context)!.noActivitiesToday)),
            )
          else
            ...List.generate(logs.length, (i) {
              final log = logs[i];
              final isLast = i == logs.length - 1;
              final timeStr = DateFormat('HH:mm').format(log.punchTime);
              final name = log.employee?.name ?? AppLocalizations.of(context)!.unknownFingerprint;
              return Padding(
                padding: EdgeInsets.only(
                  right: 16, left: 16,
                  top: 10, bottom: isLast ? 10 : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: log.employee != null
                            ? Theme.of(context).colorScheme.primary.withAlpha(20)
                            : Theme.of(context).colorScheme.absent.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        log.employee != null
                            ? Icons.person_rounded
                            : Icons.fingerprint,
                        color: log.employee != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.absent,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (log.employee == null)
                            Text(
                              AppLocalizations.of(context)!.unlinked,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.absent,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
