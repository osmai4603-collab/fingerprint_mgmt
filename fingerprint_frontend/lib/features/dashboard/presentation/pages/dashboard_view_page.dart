import 'package:flutter/material.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/core/widgets/shimmer_loading.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/today_summary_card.dart';
import '../widgets/report_list_card.dart';
import '../widgets/recent_activity_card.dart';
import 'package:fingerprint_frontend/core/theme/app_color_scheme.dart';

class DashboardViewPage extends StatefulWidget {
  const DashboardViewPage({super.key});

  @override
  State<DashboardViewPage> createState() => _DashboardViewPageState();
}

class _DashboardViewPageState extends State<DashboardViewPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.home,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return ShimmerLoading.dashboard();
          }
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.absent,
                  ),
                  SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.read<DashboardBloc>().add(
                      const LoadDashboardEvent(),
                    ),
                    icon: Icon(Icons.refresh_rounded),
                    label: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            );
          }
          if (state is DashboardLoaded) {
            return _DashboardContent(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<DashboardBloc>().add(const LoadDashboardEvent()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 20),
            TodaySummaryCard(
              presentCount: state.presentToday,
              absentCount: state.absentToday,
              lateCount: state.lateToday,
            ),
            SizedBox(height: 20),
            _buildStatCardsGrid(context, isWide),
            SizedBox(height: 20),
            _buildReportsRow(context, isWide),
            SizedBox(height: 20),
            RecentActivityCard(logs: state.recentActivity),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (_, opacity, child) {
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - opacity)),
                child: child,
              ),
            );
          },
          child: Text(
            AppLocalizations.of(context)!.dashboard,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 4),
        Text(
          AppLocalizations.of(context)!.overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCardsGrid(BuildContext context, bool isWide) {
    final crossAxisCount = isWide ? 3 : 2;
    final cards = [
      StatCard(
        icon: Icons.people_alt_rounded,
        title: AppLocalizations.of(context)!.employees,
        value: '${state.employeeCount}',
        color: Theme.of(context).colorScheme.primary,
        subtitle: AppLocalizations.of(context)!.activeEmployees(state.activeEmployeeCount),
      ),
      StatCard(
        icon: Icons.schedule_rounded,
        title: AppLocalizations.of(context)!.shifts,
        value: '${state.shiftCount}',
        color: Theme.of(context).colorScheme.secondary,
      ),
      StatCard(
        icon: Icons.fingerprint_rounded,
        title: AppLocalizations.of(context)!.devices,
        value: '${state.deviceCount}',
        color: Theme.of(context).colorScheme.tertiary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => cards[i],
    );
  }

  Widget _buildReportsRow(BuildContext context, bool isWide) {
    final reports = [
      ReportListCard.fromMostAbsent(context, state.mostAbsent),
      ReportListCard.fromMostPresent(context, state.mostPresent),
      ReportListCard.fromMostLate(context, state.mostLate),
    ];

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: reports
            .map(
              (r) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: r,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: reports
          .map(
            (r) =>
                Padding(padding: EdgeInsets.only(bottom: 12), child: r),
          )
          .toList(),
    );
  }
}
