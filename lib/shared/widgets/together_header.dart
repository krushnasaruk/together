import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/notifications/presentation/widgets/notifications_sheet.dart';
import 'mascot/together_mascot.dart';
import 'partner_switcher_badge.dart';

/// A unified, constant-dimension application header that stays stable across tabs.
/// Eliminates header height jumping and layout shifts during bottom navigation.
class TogetherHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? customAction;
  final bool showPartnerBadge;
  final bool showNotificationBell;

  const TogetherHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.customAction,
    this.showPartnerBadge = true,
    this.showNotificationBell = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadNotifs = ref.watch(unreadNotificationCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64.0,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Leading Avatar / Mascot / Custom Leading
              leading ??
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282E2A)
                          : const Color(0xFFE8EFE5),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const TogetherMascot(
                      pose: MisoPose.avatar,
                      height: 32,
                      width: 32,
                      animateOnTap: true,
                    ),
                  ),

              const SizedBox(width: AppTokens.space12),

              // 2. Title & Subtitle with fixed vertical typography
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.5,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: AppTokens.space8),

              // 3. Screen-specific custom action (e.g. "Go to Today" button)
              if (customAction != null) ...[
                customAction!,
                const SizedBox(width: 4),
              ],

              // 4. Constant Partner Switcher Badge
              if (showPartnerBadge) ...[
                const PartnerSwitcherBadge(),
                const SizedBox(width: 4),
              ],

              // 5. Constant Notifications Bell with live unread indicator
              if (showNotificationBell)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                      ),
                      tooltip: 'Notifications',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => NotificationsSheet.show(context),
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    if (unreadNotifs > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            '$unreadNotifs',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
