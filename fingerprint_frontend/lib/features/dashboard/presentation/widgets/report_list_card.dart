import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/shared/shared_core.dart';
import '../bloc/dashboard_state.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class ReportListItem {
  final String name;
  final String value;
  const ReportListItem({required this.name, required this.value});
}

class ReportListCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<ReportListItem> items;

  const ReportListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  factory ReportListCard.fromMostAbsent(BuildContext context, List<AttendanceSummaryReport> reports) {
    return ReportListCard(
      title: AppLocalizations.of(context)!.mostAbsent,
      icon: Icons.person_off_rounded,
      color: Theme.of(context).colorScheme.absent,
      items: reports
          .where((r) => r.employeeName.isNotEmpty)
          .map((r) => ReportListItem(
            name: r.employeeName,
            value: AppLocalizations.of(context)!.hoursAbbreviation(r.absenceHours),
          ))
          .toList(),
    );
  }

  factory ReportListCard.fromMostPresent(BuildContext context, List<AttendanceSummaryReport> reports) {
    return ReportListCard(
      title: AppLocalizations.of(context)!.mostPresent,
      icon: Icons.person_rounded,
      color: Theme.of(context).colorScheme.success,
      items: reports
          .where((r) => r.employeeName.isNotEmpty)
          .map((r) => ReportListItem(
            name: r.employeeName,
            value: AppLocalizations.of(context)!.hoursAbbreviation(r.workHours),
          ))
          .toList(),
    );
  }

  factory ReportListCard.fromMostLate(BuildContext context, List<LateEmployeeSummary> reports) {
    return ReportListCard(
      title: AppLocalizations.of(context)!.mostLate,
      icon: Icons.access_time_rounded,
      color: Theme.of(context).colorScheme.lateStatus,
      items: reports
          .where((r) => r.employeeName.isNotEmpty)
          .map((r) => ReportListItem(
            name: r.employeeName,
            value: AppLocalizations.of(context)!.timesCount(r.lateCount),
          ))
          .toList(),
    );
  }

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
                colors: [color.withAlpha(30), color.withAlpha(10)],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(AppLocalizations.of(context)!.noData),
              ),
            )
          else
            ...List.generate(items.length, (i) {
              final item = items[i];
              final isLast = i == items.length - 1;
              return Padding(
                padding: EdgeInsets.only(
                  right: 16, left: 16,
                  top: 10, bottom: isLast ? 10 : 0,
                ),
                child: Row(
                  children: [
                    _RankBadge(rank: i + 1, color: color),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
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

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;

  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final bgColor = isTop3 ? color.withAlpha(25) : Colors.transparent;
    final iconColor = isTop3 ? color : Theme.of(context).colorScheme.outline;

    IconData icon;
    if (rank == 1) {
      icon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      icon = Icons.workspace_premium_rounded;
    } else if (rank == 3) {
      icon = Icons.military_tech_rounded;
    } else {
      icon = Icons.circle_rounded;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor, size: rank <= 3 ? 18 : 8),
    );
  }
}
