import 'package:fingerprint_frontend/features/attendance_logs/presentation/widgets/attendance_dashboard_view.dart';
import 'package:fingerprint_frontend/features/dashboard/presentation/pages/dashboard_view_page.dart';
import 'package:fingerprint_frontend/features/employees/presentation/widgets/employees_dashboard_view.dart';
import 'package:fingerprint_frontend/features/auth/presentation/pages/users_dashboard_view.dart';
import 'package:fingerprint_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:fingerprint_frontend/features/dashboard/presentation/pages/dashboard_shell.dart';
import 'package:fingerprint_frontend/features/reports/presentation/widgets/reports_dashboard_view.dart';
import 'package:fingerprint_frontend/features/settings/presentation/widgets/settings_dashboard_view.dart';
import 'package:fingerprint_frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:fingerprint_frontend/features/system/presentation/widgets/system_dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_route_keys.dart';
import '../services/user_session.dart';
import '../di/injection_container.dart';

sealed class NavigationService {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouteKeys.splash,
    redirect: _authGuard,
    routes: [
      GoRoute(
        path: AppRouteKeys.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRouteKeys.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, routerState, navigationShell) {
          return DashboardShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.dashboard,
                builder: (context, state) {
                  return DashboardViewPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.employees,
                builder: (context, state) {
                  return EmployeesDashboardView();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.attendance,
                builder: (context, state) {
                  return const AttendanceLogDashboardView();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.reports,
                builder: (context, state) {
                  return const ReportsDashboardView();
                },
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: AppRouteKeys.leaves,
          //       builder: (context, state) {
          //         return const LeavesDashboardView();
          //       },
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: AppRouteKeys.overtime,
          //       builder: (context, state) {
          //         return const OvertimeDashboardView();
          //       },
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   routes: [
          //     GoRoute(
          //       path: AppRouteKeys.payroll,
          //       builder: (context, state) {
          //         return const PayrollDashboardView();
          //       },
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.settings,
                builder: (context, state) {
                  return SettingsDashboardView();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.system,
                builder: (context, state) {
                  return const SystemDashboardView();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.users,
                builder: (context, state) {
                  return const UsersDashboardView();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  static final _publicRoutes = <String>{
    AppRouteKeys.splash,
    AppRouteKeys.login,
  };

  static Future<String?> _authGuard(
    BuildContext context,
    GoRouterState state,
  ) async {
    if (_publicRoutes.contains(state.matchedLocation)) {
      return null;
    }

    try {
      final session = get_it<UserSession>();

      if (session.token == null || !session.isLoggedIn) {
        return AppRouteKeys.login;
      }

      if (session.isLoggedIn) {
        if (state.matchedLocation == AppRouteKeys.login) {
          return AppRouteKeys.dashboard;
        }
        return null;
      }

      return null;
    } catch (e) {
      return AppRouteKeys.login;
    }
  }
}
