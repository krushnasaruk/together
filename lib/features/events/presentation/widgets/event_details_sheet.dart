import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/models/event_model.dart';
import '../providers/event_provider.dart';
import 'event_form_sheet.dart';

/// Modal bottom sheet displaying detailed event information and management actions.
class EventDetailsSheet extends ConsumerWidget {
  final CalendarEvent event;

  const EventDetailsSheet({super.key, required this.event});

  static Future<void> show(BuildContext context, CalendarEvent event) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EventDetailsSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(authProvider).currentUser.uid;
    final isOwner = event.isOwnedBy(currentUserId);
    final isMasked = event.isMaskedFor(currentUserId);

    final title = event.displayTitleFor(currentUserId);
    final description = event.displayDescriptionFor(currentUserId);
    final location = event.displayLocationFor(currentUserId);

    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(event.startTime);
    final timeStr =
        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}';

    final partnerColor = event.ownerId == 'user_alex'
        ? AppColors.partnerSage
        : (event.ownerId == 'user_taylor'
            ? AppColors.partnerRose
            : AppColors.togetherBlue);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag bar & header
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: partnerColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.ownerName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: partnerColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.category.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(event.category.icon,
                            size: 14, color: event.category.color),
                        const SizedBox(width: 4),
                        Text(
                          event.category.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: event.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Content Body
            Flexible(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Title
                  Text(
                    title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: isMasked
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontStyle:
                              isMasked ? FontStyle.italic : FontStyle.normal,
                        ),
                  ),
                  const SizedBox(height: 14),

                  // Privacy Notice if masked
                  if (isMasked)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_rounded,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Private schedule: Your partner is busy during this slot. Specific details are hidden.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Date and Time Info Tile
                  _buildInfoTile(
                    context,
                    icon: Icons.calendar_today_rounded,
                    title: dateStr,
                    subtitle: timeStr,
                  ),
                  const SizedBox(height: 12),

                  // Location (if not masked and present)
                  if (location != null) ...[
                    _buildInfoTile(
                      context,
                      icon: Icons.place_outlined,
                      title: location,
                      subtitle: 'Location / Venue',
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Description / Notes
                  if (description != null) ...[
                    _buildInfoTile(
                      context,
                      icon: Icons.notes_rounded,
                      title: description,
                      subtitle: 'Notes & Context',
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Status and Visibility Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.status.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: event.status.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          event.visibility.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Event Operations (Only if owner or shared)
                  if (isOwner) ...[
                    Text(
                      'Manage Event',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            EventFormSheet.show(context, event: event);
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Duplicate'),
                          onPressed: () {
                            ref
                                .read(eventProvider.notifier)
                                .duplicateEvent(event.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Event duplicated for tomorrow.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        if (event.status != EventStatus.completed)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                size: 16),
                            label: const Text('Mark Completed'),
                            onPressed: () {
                              ref.read(eventProvider.notifier).updateStatus(
                                  event.id, EventStatus.completed);
                              Navigator.of(context).pop();
                            },
                          ),
                        if (event.status != EventStatus.cancelled)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.cancel_outlined, size: 16),
                            label: const Text('Cancel Event'),
                            onPressed: () {
                              ref.read(eventProvider.notifier).updateStatus(
                                  event.id, EventStatus.cancelled);
                              Navigator.of(context).pop();
                            },
                          ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.statusCancelled),
                          label: const Text(
                            'Delete',
                            style: TextStyle(color: AppColors.statusCancelled),
                          ),
                          onPressed: () {
                            ref
                                .read(eventProvider.notifier)
                                .deleteEvent(event.id);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Event removed from calendar.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TogetherSurface(
      surfaceType: ClaySurfaceType.flat,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      padding: const EdgeInsets.all(14),
      borderColor: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }
}
