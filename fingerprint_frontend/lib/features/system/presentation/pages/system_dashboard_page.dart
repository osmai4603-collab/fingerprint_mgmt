import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../widgets/shifts_list_view.dart';
import '../widgets/devices_list_view.dart';

class SystemDashboardPage extends StatefulWidget {
  const SystemDashboardPage({super.key});

  @override
  State<SystemDashboardPage> createState() => _SystemDashboardPageState();
}

class _SystemDashboardPageState extends State<SystemDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withAlpha(180)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.settings_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.system,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(150),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(icon: Icon(Icons.schedule_rounded), text: AppLocalizations.of(context)!.shifts),
            Tab(icon: Icon(Icons.fingerprint_rounded), text: AppLocalizations.of(context)!.devices),
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
          children: [const ShiftsListView(), const DevicesListView()],
        ),
      ),
    );
  }
}

class _SystemMainView extends StatelessWidget {
  final void Function(int index) onNavigate;

  const _SystemMainView({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _CardData(
        icon: Icons.schedule_rounded,
        title: AppLocalizations.of(context)!.shifts,
        description: AppLocalizations.of(context)!.shiftManagementCardDesc,
        color: Theme.of(context).colorScheme.primary,
        tabIndex: 1,
      ),
      _CardData(
        icon: Icons.fingerprint_rounded,
        title: AppLocalizations.of(context)!.deviceManagement,
        description: AppLocalizations.of(context)!.deviceManagementCardDesc,
        color: Theme.of(context).colorScheme.tertiary,
        tabIndex: 2,
      ),
    ];

    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.systemDashboard,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.systemSettingsDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: List.generate(cards.length, (index) {
                final card = cards[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 400 + index * 120),
                  curve: Curves.easeOutCubic,
                  builder: (_, opacity, child) {
                    return Opacity(
                      opacity: opacity,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - opacity)),
                        child: Transform.scale(
                          scale: 0.9 + 0.1 * opacity,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildCard(
                    context,
                    icon: card.icon,
                    title: card.title,
                    description: card.description,
                    color: card.color,
                    onTap: () => onNavigate(card.tabIndex),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int tabIndex;

  const _CardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.tabIndex,
  });
}
