import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class TodaySummaryCard extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final int lateCount;

  const TodaySummaryCard({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8, bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.today_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.todaySummary,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(child: _MiniStat(
                  icon: Icons.check_circle_rounded,
                  label: AppLocalizations.of(context)!.present,
                  count: presentCount,
                  color: Theme.of(context).colorScheme.success,
                )),
                Expanded(child: _MiniStat(
                  icon: Icons.cancel_rounded,
                  label: AppLocalizations.of(context)!.absent,
                  count: absentCount,
                  color: Theme.of(context).colorScheme.absent,
                )),
                Expanded(child: _MiniStat(
                  icon: Icons.warning_amber_rounded,
                  label: AppLocalizations.of(context)!.lateStatus,
                  count: lateCount,
                  color: Theme.of(context).colorScheme.lateStatus,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 6),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
