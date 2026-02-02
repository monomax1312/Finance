import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/dashboard_screen.dart';
import '../ui/screens/home_shell.dart';
import '../ui/screens/notifications_screen.dart';
import '../ui/screens/notification_rules_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/stats_screen.dart';
import '../ui/screens/transactions_screen.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/notification-rules',
          pageBuilder: (context, state) => _buildPage(
            state,
            const NotificationRulesScreen(),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => _buildPage(
                state,
                const DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) => _buildPage(
                state,
                const TransactionsScreen(),
              ),
            ),
            GoRoute(
              path: '/stats',
              pageBuilder: (context, state) => _buildPage(
                state,
                const StatsScreen(),
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => _buildPage(
                state,
                const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _buildPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
