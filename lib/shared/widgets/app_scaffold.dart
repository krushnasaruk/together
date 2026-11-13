import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/onboarding/guided_tour_registry.dart';
import '../../core/onboarding/widgets/guided_tour_overlay.dart';

/// Root scaffold hosting the persistent bottom navigation bar and
/// providing the top-level overlay for Miso's Little Guide.
class AppScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey _todayKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _togetherKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    GuidedTourRegistry.register('tour_nav_today', _todayKey);
    GuidedTourRegistry.register('tour_nav_calendar', _calendarKey);
    GuidedTourRegistry.register('tour_nav_together', _togetherKey);
    GuidedTourRegistry.register('tour_nav_profile', _profileKey);
  }

  @override
  void dispose() {
    GuidedTourRegistry.unregister('tour_nav_today');
    GuidedTourRegistry.unregister('tour_nav_calendar');
    GuidedTourRegistry.unregister('tour_nav_together');
    GuidedTourRegistry.unregister('tour_nav_profile');
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    HapticFeedback.lightImpact();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GuidedTourOverlay(
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                offset: Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: NavigationBar(
              selectedIndex: widget.navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor:
                  isDark ? const Color(0xFF3B483D) : const Color(0xFFE4EDE0),
              destinations: [
                NavigationDestination(
                  key: _todayKey,
                  icon: const Icon(Icons.wb_sunny_outlined),
                  selectedIcon: const Icon(Icons.wb_sunny_rounded),
                  label: 'Today',
                  tooltip: 'Today screen',
                ),
                NavigationDestination(
                  key: _calendarKey,
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month_rounded),
                  label: 'Calendar',
                  tooltip: 'Calendar schedule view',
                ),
                NavigationDestination(
                  key: _togetherKey,
                  icon: const Icon(Icons.favorite_border_rounded),
                  selectedIcon: const Icon(Icons.favorite_rounded),
                  label: 'Together',
                  tooltip: 'Together relationship space',
                ),
                NavigationDestination(
                  key: _profileKey,
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: 'Profile',
                  tooltip: 'Profile and settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
