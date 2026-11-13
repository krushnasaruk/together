import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/clay/clay_button.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/components/event_timeline_tile.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../../shared/widgets/components/together_avatar.dart';
import '../../../../shared/widgets/mascot/mascot_states.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../../shared/widgets/motion/text_animations.dart';
import '../../../../shared/widgets/together_header.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../availability/presentation/providers/availability_provider.dart';
import '../../../availability/presentation/providers/status_provider.dart';
import '../../../availability/presentation/widgets/status_picker_sheet.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/widgets/event_details_sheet.dart';
import '../../../events/presentation/widgets/event_form_sheet.dart';
import '../../../notifications/domain/models/notification_model.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../pairing/presentation/widgets/pairing_sheet.dart';

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

    final currentUserStatus = ref.watch(currentUserStatusProvider);
    final partnerStatus = ref.watch(partnerStatusProvider);
    final misoGreetingDismissed = ref.watch(misoGreetingDismissedProvider);

    // Watch today's events dynamically
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
      appBar: TogetherHeader(
        title: 'Today',
        subtitle: formattedDate,
      ),
      body: RefreshIndicator(
        color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
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
                message: currentUser.isPaired
                    ? 'Hi ${currentUser.displayName.isNotEmpty ? currentUser.displayName.split(' ').first : 'there'}! Miso is keeping your and ${partnerName.split(' ').first}\'s days in sync.'
                    : 'Hi ${currentUser.displayName.isNotEmpty ? currentUser.displayName.split(' ').first : 'there'}! Welcome to Together. Let\'s coordinate your day.',
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16),
                  onPressed: () => ref
                      .read(misoGreetingDismissedProvider.notifier)
                      .state = true,
                ),
              ),
              const SizedBox(height: AppTokens.space16),
            ],

            // 1. Dynamic Daily Stats Bar (Real-time reactive counter)
            _buildDynamicStatsBar(
              context,
              todayEventsCount: todayEvents.length,
              freeWindows: freeWindows,
              sharedEventsCount: sharedEvents.length,
              isDark: isDark,
            ),
            const SizedBox(height: AppTokens.space16),

            // 2. Active User Status Bar (Instant 1-tap update & live feedback)
            _buildMyStatusCard(
              context,
              ref: ref,
              currentUserStatus: currentUserStatus,
              isDark: isDark,
            ),
            const SizedBox(height: AppTokens.space16),

            if (!currentUser.isPaired) ...[
              // Pairing Invite Banner when not paired yet
              _buildPairingInviteBanner(context, isDark: isDark),
              const SizedBox(height: AppTokens.space20),
            ] else ...[
              // 3. Partner-First Overview Card with Poke & Nudge
              _buildPartnerOverviewCard(
                context,
                ref: ref,
                currentUserId: currentUser.uid,
                currentUserName: currentUser.displayName,
                partnerName: partnerName,
                partnerStatus: partnerStatus,
                partnerEvents: partnerEvents,
                isDark: isDark,
              ),
              const SizedBox(height: AppTokens.space20),

              // 4. Potential Time Together (Shared Free Windows)
              if (freeWindows.isNotEmpty) ...[
                _buildPotentialTimeTogetherCard(
                  context,
                  freeWindows: freeWindows,
                  isDark: isDark,
                ),
                const SizedBox(height: AppTokens.space20),
              ],

              // 5. Shared Together Plans (if any today)
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

              // 6. Partner's Schedule Section (Partner-First Principle)
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
            ],

            // 7. User's Own Schedule Section
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

  /// Pairing invitation banner shown when user has not yet paired with a partner
  Widget _buildPairingInviteBanner(BuildContext context, {required bool isDark}) {
    return TogetherSurface(
      surfaceType: ClaySurfaceType.raised,
      padding: const EdgeInsets.all(AppTokens.space20),
      child: Column(
        children: [
          Row(
            children: [
              const TogetherMascot(
                pose: MisoPose.curious,
                width: 58,
                height: 58,
              ),
              const SizedBox(width: AppTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Two Lives. One Space.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Link with your partner to coordinate schedules, share availability, and sync plans in real time.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space16),
          ClayButton(
            label: 'Pair with Partner',
            icon: const Icon(Icons.link_rounded, size: 18),
            onPressed: () => PairingSheet.show(context),
            expanded: true,
          ),
        ],
      ),
    );
  }

  /// Dynamic real-time stats overview bar
  Widget _buildDynamicStatsBar(
    BuildContext context, {
    required int todayEventsCount,
    required List<dynamic> freeWindows,
    required int sharedEventsCount,
    required bool isDark,
  }) {
    int totalFreeMinutes = 0;
    for (final w in freeWindows) {
      totalFreeMinutes += (w.duration.inMinutes as int);
    }
    final freeHours = (totalFreeMinutes / 60).toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _buildStatCapsule(
            icon: Icons.event_note_rounded,
            label: '$todayEventsCount',
            sublabel: 'Events',
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppTokens.space8),
        Expanded(
          child: _buildStatCapsule(
            icon: Icons.timelapse_rounded,
            label: '${freeHours}h',
            sublabel: 'Overlap Free',
            color: AppColors.togetherBlue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: AppTokens.space8),
        Expanded(
          child: _buildStatCapsule(
            icon: Icons.favorite_rounded,
            label: '$sharedEventsCount',
            sublabel: 'Shared',
            color: AppColors.partnerRose,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCapsule({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Interactive User Status Card with 1-tap quick presets
  Widget _buildMyStatusCard(
    BuildContext context, {
    required WidgetRef ref,
    required StatusUpdate? currentUserStatus,
    required bool isDark,
  }) {
    final statusText = currentUserStatus != null
        ? '${currentUserStatus.preset.emoji} ${currentUserStatus.preset.title}${currentUserStatus.customNote != null && currentUserStatus.customNote!.isNotEmpty ? " • \"${currentUserStatus.customNote}\"" : ""}'
        : 'Tap below to set your status';

    return TogetherSurface(
      surfaceType: ClaySurfaceType.raised,
      padding: const EdgeInsets.all(AppTokens.space14),
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Status',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                tooltip: 'Customize status',
                visualDensity: VisualDensity.compact,
                onPressed: () => StatusPickerSheet.show(context),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space10),
          // 1-Tap Quick Presets Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickPresetChip(
                  preset: QuickStatusPreset.freeNow,
                  isSelected:
                      currentUserStatus?.preset == QuickStatusPreset.freeNow,
                  onTap: () => ref
                      .read(statusProvider.notifier)
                      .setStatus(preset: QuickStatusPreset.freeNow),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildQuickPresetChip(
                  preset: QuickStatusPreset.needFocus,
                  isSelected:
                      currentUserStatus?.preset == QuickStatusPreset.needFocus,
                  onTap: () => ref
                      .read(statusProvider.notifier)
                      .setStatus(preset: QuickStatusPreset.needFocus),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildQuickPresetChip(
                  preset: QuickStatusPreset.onMyWay,
                  isSelected:
                      currentUserStatus?.preset == QuickStatusPreset.onMyWay,
                  onTap: () => ref
                      .read(statusProvider.notifier)
                      .setStatus(preset: QuickStatusPreset.onMyWay),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildQuickPresetChip(
                  preset: QuickStatusPreset.takingBreak,
                  isSelected:
                      currentUserStatus?.preset == QuickStatusPreset.takingBreak,
                  onTap: () => ref
                      .read(statusProvider.notifier)
                      .setStatus(preset: QuickStatusPreset.takingBreak),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresetChip({
    required QuickStatusPreset preset,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : (isDark ? const Color(0xFF262C27) : const Color(0xFFF0EFEA)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(preset.emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(
              preset.title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerOverviewCard(
    BuildContext context, {
    required WidgetRef ref,
    required String currentUserId,
    required String currentUserName,
    required String partnerName,
    required dynamic partnerStatus,
    required List<CalendarEvent> partnerEvents,
    required bool isDark,
  }) {
    final nextEvent = partnerEvents
        .where((e) => e.endTime.isAfter(DateTime.now()))
        .toList()
        .firstOrNull;

    return TogetherSurface(
      surfaceType: ClaySurfaceType.raised,
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
                            color: AppColors.partnerRose.withOpacity(0.12),
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
                    AnimatedStatusText(
                      text: partnerStatus != null
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
              // Playful Poke / Nudge Action Button ("콕 찌르기")
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(notificationProvider.notifier)
                      .dispatchNotificationToPartner(
                        senderId: currentUserId,
                        senderName: currentUserName,
                        type: NotificationType.statusUpdate,
                        title:
                            '👉 Poke from ${currentUserName.split(' ').first}!',
                        body:
                            '${currentUserName.split(' ').first} sent you a gentle poke! "Thinking of you 💕"',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Poked ${partnerName.split(' ').first}! 👉'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Text('👉', style: TextStyle(fontSize: 13)),
                label: const Text('Poke', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.partnerRose.withOpacity(0.15),
                  foregroundColor: AppColors.partnerRose,
                  elevation: 0,
                  minimumSize: const Size(64, 34),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          if (nextEvent != null) ...[
            const SizedBox(height: AppTokens.space12),
            TogetherSurface(
              surfaceType: ClaySurfaceType.inset,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space8,
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
                      nextEvent.displayTitleFor(currentUserId),
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
    return TogetherSurface(
      surfaceType: ClaySurfaceType.raised,
      accentColor: AppColors.togetherBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.space6),
                decoration: BoxDecoration(
                  color: AppColors.togetherBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  size: 16,
                  color: AppColors.togetherBlue,
                ),
              ),
              const SizedBox(width: AppTokens.space8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Time Together',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      '${freeWindows.length} free window${freeWindows.length > 1 ? 's' : ''} available today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          Wrap(
            spacing: AppTokens.space8,
            runSpacing: AppTokens.space8,
            children: freeWindows.map((window) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space10,
                  vertical: AppTokens.space6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF242A27)
                      : AppColors.togetherBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(
                    color: AppColors.togetherBlue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.togetherBlue,
                    ),
                    const SizedBox(width: AppTokens.space6),
                    Text(
                      '${DateFormat('h:mm a').format(window.start)} – ${DateFormat('h:mm a').format(window.end)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.togetherBlue,
                      ),
                    ),
                    const SizedBox(width: AppTokens.space4),
                    Text(
                      '(${window.duration.inMinutes}m)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
