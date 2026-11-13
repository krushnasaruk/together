import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/components/cards/hero_panel.dart';
import '../../../../shared/widgets/components/event_timeline_tile.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/together_avatar.dart';
import '../../../../shared/widgets/mascot/mascot_states.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/partner_switcher_badge.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../availability/presentation/providers/availability_provider.dart';
import '../../../availability/presentation/providers/status_provider.dart';
import '../../../availability/presentation/widgets/status_picker_sheet.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/widgets/event_details_sheet.dart';
import '../../../events/presentation/widgets/event_form_sheet.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../notifications/presentation/widgets/notifications_sheet.dart';
import '../../../together_time/presentation/widgets/add_plan_sheet.dart';

/// Tracks whether Miso has greeted the user during the current session
final misoGreetingDismissedProvider = StateProvider<bool>((ref) => false);

/// The primary home screen displaying today's schedule for both partners.
/// Redesigned with Together's warm, clean, hand-drawn and playful Miso visual identity.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    final auth = ref.watch(authProvider);
    final currentUser = auth.currentUser;
    final partnerName = currentUser.partnerName ?? 'Partner';

    final partnerStatus = ref.watch(partnerStatusProvider);
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);
    final misoGreetingDismissed = ref.watch(misoGreetingDismissedProvider);

    // Watch today's events
    final todayEvents = ref.watch(eventsForDateProvider(today));
    final freeWindows = ref.watch(sharedFreeWindowsProvider(today));

    final myEvents =
        todayEvents.where((e) => e.ownerId == currentUser.uid).toList();
    final partnerEvents = todayEvents
        .where((e) => e.ownerId != currentUser.uid && e.ownerId != 'together')
        .toList();
    final sharedEvents = todayEvents
        .where((e) => e.ownerName.contains('&') || e.ownerId == 'together')
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const TogetherMascot(
              pose: MisoPose.avatar,
              height: 38,
              width: 38,
              animateOnTap: true,
            ),
            const SizedBox(width: AppTokens.space10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Good day, ${currentUser.displayName.split(' ').first}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const PartnerSwitcherBadge(),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Notifications',
                onPressed: () => NotificationsSheet.show(context),
              ),
              if (unreadNotifs > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unreadNotifs',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppTokens.space8),
        ],
      ),
      body: RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
        onRefresh: () async {
          // Subtle refresh simulation
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space16,
            vertical: AppTokens.space12,
          ),
          children: [
            // Miso Greeting Moment (Gentle, dismissible, doesn't repeat on rebuild)
            if (!misoGreetingDismissed) ...[
              MascotMessage(
                pose: MisoPose.wave,
                message:
                    'Hi ${currentUser.displayName.split(' ').first}! Miso is keeping your and ${partnerName.split(' ').first}\'s days in sync.',
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => ref
                      .read(misoGreetingDismissedProvider.notifier)
                      .state = true,
                ),
              ),
              const SizedBox(height: AppTokens.space16),
            ],

            // Partner-First Overview Card
            _buildPartnerOverviewCard(
              context,
              partnerName: partnerName,
              partnerStatus: partnerStatus,
              partnerEvents: partnerEvents,
              isDark: isDark,
            ),
            const SizedBox(height: AppTokens.space20),

            // Potential Time Together (Shared Free Windows)
            if (freeWindows.isNotEmpty) ...[
              _buildPotentialTimeTogetherCard(
                context,
                freeWindows: freeWindows,
                isDark: isDark,
              ),
              const SizedBox(height: AppTokens.space20),
            ],

            // Shared Together Plans (if any today)
            if (sharedEvents.isNotEmpty) ...[
              const SectionHeader(
                title: 'Together Tonight',
                subtitle: 'Plans shared between both of you',
                icon: Icons.favorite_rounded,
                padding: EdgeInsets.only(bottom: AppTokens.space8),
              ),
              ...sharedEvents.map(
                (event) => EventTimelineTile(
                  event: event,
                  currentUserId: currentUser.uid,
                  onTap: () => EventDetailsSheet.show(context, event),
                ),
              ),
              const SizedBox(height: AppTokens.space16),
            ],

            // Partner's Schedule Section (Partner-First Principle)
            SectionHeader(
              title: "${partnerName.split(' ').first}'s Schedule",
              subtitle: 'Daily commitments & busy intervals',
              icon: Icons.person_outline_rounded,
              padding: const EdgeInsets.only(bottom: AppTokens.space8),
            ),
            if (partnerEvents.isEmpty)
              MascotEmptyState(
                title: 'No events scheduled',
                message:
                    '${partnerName.split(' ').first} has not scheduled any events for today yet.',
                pose: MisoPose.sleeping,
                mascotHeight: 90,
              )
            else
              ...partnerEvents.map(
                (event) => EventTimelineTile(
                  event: event,
                  currentUserId: currentUser.uid,
                  isPast: event.endTime.isBefore(now),
                  onTap: () => EventDetailsSheet.show(context, event),
                ),
              ),
            const SizedBox(height: AppTokens.space24),

            // User's Own Schedule Section
            const SectionHeader(
              title: 'Your Schedule',
              subtitle: 'Your plans and personal commitments',
              icon: Icons.calendar_today_outlined,
              padding: EdgeInsets.only(bottom: AppTokens.space8),
            ),
            if (myEvents.isEmpty)
              MascotEmptyState(
                title: 'Your day is open',
                message:
                    'You have no scheduled plans for today. Tap below to add your plans.',
                pose: MisoPose.curious,
                mascotHeight: 90,
                actionLabel: 'Add an Event',
                onAction: () =>
                    EventFormSheet.show(context, defaultDate: today),
              )
            else
              ...myEvents.map(
                (event) => EventTimelineTile(
                  event: event,
                  currentUserId: currentUser.uid,
                  isPast: event.endTime.isBefore(now),
                  onTap: () => EventDetailsSheet.show(context, event),
                ),
              ),
            const SizedBox(height: 88), // Padding for floating action button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => EventFormSheet.show(context, defaultDate: today),
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
        foregroundColor:
            isDark ? AppColors.darkBackground : AppColors.textInverse,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPartnerOverviewCard(
    BuildContext context, {
    required String partnerName,
    required dynamic partnerStatus,
    required List<CalendarEvent> partnerEvents,
    required bool isDark,
  }) {
    final nextEvent = partnerEvents
        .where((e) => e.endTime.isAfter(DateTime.now()))
        .toList()
        .firstOrNull;

    return HeroPanel(
      accentColor: AppColors.partnerRose,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TogetherAvatar(
                name: partnerName,
                size: 44,
                borderColor: AppColors.partnerRose,
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          partnerName,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.partnerRose.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Partner',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.partnerRose,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partnerStatus != null
                          ? '${partnerStatus.preset.emoji} ${partnerStatus.preset.title}${partnerStatus.customNote != null && partnerStatus.customNote!.isNotEmpty ? " • \"${partnerStatus.customNote}\"" : ""}'
                          : '🌿 Active in workspace',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => StatusPickerSheet.show(context),
                icon: const Icon(Icons.bolt_rounded, size: 14),
                label: const Text('Status', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(70, 34),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: AppTokens.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space8,
              ),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF242A25) : const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.partnerRose,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    'Up next: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      nextEvent.displayTitleFor(
                          partnerEvents.firstOrNull?.ownerId ?? ''),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(nextEvent.startTime),
                    style: AppTypography.scheduleTimeStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPotentialTimeTogetherCard(
    BuildContext context, {
    required List<dynamic> freeWindows,
    required bool isDark,
  }) {
    return HeroPanel(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TogetherMascot(
                pose: MisoPose.happy,
                height: 34,
                width: 34,
              ),
              const SizedBox(width: AppTokens.space10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Time Together',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Overlapping free windows suggested by Miso',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => AddPlanSheet.show(context),
                child: const Text('Plan', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space10),
          ...freeWindows.take(2).map((window) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space8,
              ),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF28342B) : const Color(0xFFF2F6F1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_rounded,
                    size: 14,
                    color: Color(0xFF6B8A70),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Text(
                    window.formattedTime as String,
                    style: AppTypography.scheduleTimeStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      window.suggestion as String,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
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
