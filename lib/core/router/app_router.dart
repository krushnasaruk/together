import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/calendar/presentation/screens/today_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/together_time/presentation/screens/together_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _todayNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'today');
final _calendarNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'calendar');
final _togetherNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'together');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Riverpod provider delivering the application's GoRouter configuration.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/today',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 0: Today Branch
          StatefulShellBranch(
            navigatorKey: _todayNavigatorKey,
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),

          // 1: Calendar Branch
          StatefulShellBranch(
            navigatorKey: _calendarNavigatorKey,
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),

          // 2: Together Branch
          StatefulShellBranch(
            navigatorKey: _togetherNavigatorKey,
            routes: [
              GoRoute(
                path: '/together',
                builder: (context, state) => const TogetherScreen(),
              ),
            ],
          ),

          // 3: Profile Branch
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
