import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/clay/together_surface.dart';
import '../../../../shared/widgets/mascot/mascot_states.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/notification_provider.dart';

/// Modal bottom sheet displaying recent partner notifications and activity history.
class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsSheet(),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = ref.watch(authProvider).currentUser.uid;
    final notifications = ref
        .watch(notificationProvider)
        .where((n) => n.recipientId == currentUserId)
        .toList();

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
          children: [
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
                  Text(
                    'Partner Activity',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const Spacer(),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(notificationProvider.notifier)
                            .markAllAsRead(currentUserId);
                      },
                      child: const Text('Mark all read'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(
                      child: MascotEmptyState(
                        title: 'All caught up',
                        message: 'No new updates from your partner right now.',
                        pose: MisoPose.sleeping,
                        mascotHeight: 85,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return TogetherSurface(
                          surfaceType: notif.isRead
                              ? ClaySurfaceType.flat
                              : ClaySurfaceType.raised,
                          onTap: () {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(notif.id);
                          },
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusMd),
                          borderColor: notif.isRead
                              ? (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.borderSubtle)
                              : AppColors.partnerSage.withOpacity(0.5),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A362D)
                                      : AppColors.partnerSageLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  notif.type.icon,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.partnerSageDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: notif.isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w600,
                                              color: isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatTimeAgo(notif.createdAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif.body,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notif.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.partnerSage,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
