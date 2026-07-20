import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingerprint_frontend/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fingerprint_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:fingerprint_frontend/core/constants/app_route_keys.dart';
import 'package:fingerprint_frontend/core/localization/l10n/app_localizations.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int get _currentIndex => widget.navigationShell.currentIndex;

  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  void _onLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.confirmLogoutMessage),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(ctx),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go(AppRouteKeys.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    IconData selectedIcon,
  ) {
    final isSelected = _currentIndex == index;
    return ListTileWidget(
      padding: .symmetric(horizontal: 12, vertical: 6),
      borderRadius: .circular(6.0),
      tileColor: isSelected
          ? Theme.of(context).colorScheme.primary.withAlpha(30)
          : null,
      leading: Icon(
        isSelected ? selectedIcon : icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        size: 18,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      onTap: () => _onDestinationSelected(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 900;

    final drawerContent = Drawer(
      elevation: isDesktop ? 0 : 16,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.fingerprint_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.attendanceManagementSystem,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.proPlusAttendance,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 1,
                  children: [
                    _buildNavItem(
                      0,
                      AppLocalizations.of(context)!.home,
                      Icons.home_outlined,
                      Icons.home_rounded,
                    ),
                    _buildNavItem(
                      1,
                      AppLocalizations.of(context)!.employees,
                      Icons.people_outline,
                      Icons.people_rounded,
                    ),
                    _buildNavItem(
                      2,
                      AppLocalizations.of(context)!.attendance,
                      Icons.access_time_outlined,
                      Icons.access_time_rounded,
                    ),
                    _buildNavItem(
                      3,
                      AppLocalizations.of(context)!.reports,
                      Icons.bar_chart_outlined,
                      Icons.bar_chart_rounded,
                    ),
                    _buildNavItem(
                      4,
                      AppLocalizations.of(context)!.settings,
                      Icons.settings_outlined,
                      Icons.settings_rounded,
                    ),
                    _buildNavItem(
                      5,
                      AppLocalizations.of(context)!.system,
                      Icons.tune_outlined,
                      Icons.tune_rounded,
                    ),
                    _buildNavItem(
                      6,
                      AppLocalizations.of(context)!.usersManagement,
                      Icons.contact_page_outlined,
                      Icons.contact_page_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 24),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  minLeadingWidth: 24,
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: _onLogout,
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      drawer: isDesktop ? null : drawerContent,
      body: isDesktop
          ? Row(
              children: [
                drawerContent,
                Expanded(child: widget.navigationShell),
              ],
            )
          : widget.navigationShell,
    );
  }
}

class ListTileWidget extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;
  final void Function()? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? tileColor;
  final BorderRadius? borderRadius;
  final BorderSide? side;

  const ListTileWidget({
    super.key,
    required this.child,
    this.padding = const .all(4),
    this.leading,
    this.onTap,
    this.trailing,
    this.tileColor,
    this.borderRadius,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: borderRadius,
          border: side == null ? null : Border.fromBorderSide(side!),
          shape: .rectangle,
        ),
        padding: padding,
        child: Row(
          crossAxisAlignment: .center,
          textBaseline: .alphabetic,

          spacing: 4,
          children: [
            ?leading,
            Expanded(child: child),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
