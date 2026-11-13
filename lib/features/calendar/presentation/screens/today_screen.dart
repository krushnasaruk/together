import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
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

/// The primary home screen displaying today's schedule for both partners.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final formattedDate = DateFormat('EEEE, MMMM d').format(now);

    final auth = ref.watch(authProvider);
    final currentUser = auth.currentUser;
    final partnerName = currentUser.partnerName ?? 'Partner';

    final partnerStatus = ref.watch(partnerStatusProvider);
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);

    // Watch today's events
    final todayEvents = ref.watch(eventsForDateProvider(today));
    final freeWindows = ref.watch(sharedFreeWindowsProvider(today));
    final myEvents =
        todayEvents.where((e) => e.ownerId == currentUser.uid).toList();
    final partnerEvents = todayEvents
        .where((e) => e.ownerId != currentUser.uid && e.ownerId != 'together')
        .toList();
    final sharedEvents =
        todayEvents.where((e) => e.ownerName.contains('&')).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Good day, ${currentUser.displayName.split(' ').first}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(width: 8),
                const PartnerSwitcherBadge(),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.headlineMedium,
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
                      color: AppColors.partnerRose,
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
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Partner Status Card & Broadcast Trigger
          _buildPartnerStatusCard(context, partnerName, partnerStatus),
          const SizedBox(height: 20),

          // Potential Time Together (Sections 4.2 & 4.5)
          if (freeWindows.isNotEmpty) ...[
            _buildPotentialTimeTogetherCard(context, freeWindows),
            const SizedBox(height: 24),
          ],

          // Shared Together Moments (if any today)
          if (sharedEvents.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              title: 'Together Tonight',
              color: AppColors.togetherBlue,
            ),
            const SizedBox(height: 10),
            ...sharedEvents.map(
              (event) => _buildEventItem(
                  context, event, currentUser.uid, AppColors.togetherBlue),
            ),
            const SizedBox(height: 20),
          ],

          // Partner's Schedule Section
          _buildSectionHeader(
            context,
            title: "${partnerName.split(' ').first}'s Schedule",
            color: currentUser.uid == 'user_alex'
                ? AppColors.partnerRose
                : AppColors.partnerSage,
          ),
          const SizedBox(height: 10),
          if (partnerEvents.isEmpty)
            _buildEmptyScheduleCard(
              context,
              color: currentUser.uid == 'user_alex'
                  ? AppColors.partnerRose
                  : AppColors.partnerSage,
              message: '$partnerName has no events scheduled for today.',
            )
          else
            ...partnerEvents.map(
              (event) => _buildEventItem(
                context,
                event,
                currentUser.uid,
                currentUser.uid == 'user_alex'
                    ? AppColors.partnerRose
                    : AppColors.partnerSage,
              ),
            ),
          const SizedBox(height: 24),

          // User's Own Schedule Section
          _buildSectionHeader(
            context,
            title: 'Your Schedule',
            color: currentUser.themeColor,
          ),
          const SizedBox(height: 10),
          if (myEvents.isEmpty)
            _buildEmptyScheduleCard(
              context,
              color: currentUser.themeColor,
              message:
                  'Your day is open. Tap the button below to add your plans.',
            )
          else
            ...myEvents.map(
              (event) => _buildEventItem(
                  context, event, currentUser.uid, currentUser.themeColor),
            ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => EventFormSheet.show(context, defaultDate: today),
        backgroundColor: currentUser.themeColor,
        foregroundColor: AppColors.textInverse,
        elevation: 1,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Add Event',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget _buildPartnerStatusCard(
    BuildContext context,
    String partnerName,
    dynamic partnerStatus,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  partnerStatus?.preset.emoji ?? '🌿',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerStatus != null
                          ? '$partnerName: ${partnerStatus.preset.title}'
                          : '$partnerName is in sync',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      partnerStatus?.customNote != null &&
                              partnerStatus.customNote!.isNotEmpty
                          ? '"${partnerStatus.customNote}"'
                          : 'Voluntary availability status',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () => StatusPickerSheet.show(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child:
                    const Text('Update Mine', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPotentialTimeTogetherCard(
    BuildContext context,
    List<dynamic> freeWindows,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.togetherBlueLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  size: 18,
                  color: AppColors.togetherBlue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Potential Time Together',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Suggested overlapping free windows (informational only)',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => AddPlanSheet.show(context),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text('Plan', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          ...freeWindows.take(2).map((window) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined,
                      size: 14, color: AppColors.togetherBlue),
                  const SizedBox(width: 8),
                  Text(
                    window.formattedTime as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      window.suggestion as String,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
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

  Widget _buildEventItem(
    BuildContext context,
    CalendarEvent event,
    String currentUserId,
    Color accentColor,
  ) {
    final isMasked = event.isMaskedFor(currentUserId);
    final displayTitle = event.displayTitleFor(currentUserId);
    final location = event.displayLocationFor(currentUserId);
    final timeStr =
        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => EventDetailsSheet.show(context, event),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: isMasked ? AppColors.textTertiary : accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontStyle: isMasked
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isMasked
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                          ),
                        ),
                        if (isMasked)
                          const Icon(Icons.lock_outline_rounded,
                              size: 14, color: AppColors.textTertiary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (location != null) ...[
                          const SizedBox(width: 10),
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScheduleCard(
    BuildContext context, {
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
