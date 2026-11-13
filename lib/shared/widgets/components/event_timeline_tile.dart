import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/events/domain/models/event_model.dart';

/// Reusable event tile for chronological timelines in Today and Calendar screens.
class EventTimelineTile extends StatelessWidget {
  final CalendarEvent event;
  final String currentUserId;
  final VoidCallback? onTap;
  final bool isPast;

  const EventTimelineTile({
    super.key,
    required this.event,
    required this.currentUserId,
    this.onTap,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMine = event.isOwnedBy(currentUserId);
    final isSharedPlan =
        event.ownerName.contains('&') || event.ownerId == 'together';

    final Color accentColor = isSharedPlan
        ? AppColors.togetherBlue
        : (isMine ? AppColors.partnerSage : AppColors.partnerRose);

    final isMasked = event.isMaskedFor(currentUserId);
    final displayTitle = event.displayTitleFor(currentUserId);
    final displayLocation = event.displayLocationFor(currentUserId);

    final timeFormatter = DateFormat('h:mm a');
    final timeRange =
        '${timeFormatter.format(event.startTime)} – ${timeFormatter.format(event.endTime)}';

    final bool isCancelled = event.status == EventStatus.cancelled;

    final double opacity = (isPast || isCancelled) ? 0.65 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Semantics(
        label:
            '${isMine ? "My event" : "${event.ownerName}'s event"}: $displayTitle, at $timeRange',
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(AppTokens.space12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
                width: 1,
              ),
              boxShadow: isPast ? null : AppTokens.softShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left vertical color accent bar
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),

                // Main event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isCancelled
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isMasked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF384039)
                                    : const Color(0xFFEFECE6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Private',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isMine
                                    ? 'You'
                                    : (isSharedPlan
                                        ? 'Together'
                                        : event.ownerName.split(' ').first),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Time range using tabular figures
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeRange,
                            style: AppTypography.scheduleTimeStyle(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (displayLocation != null &&
                              displayLocation.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                displayLocation,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Category icon badge
                const SizedBox(width: AppTokens.space8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C322E)
                        : const Color(0xFFF4EFE6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    event.category.icon,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
