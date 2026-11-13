import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/mascot/together_mascot.dart';
import '../../domain/models/notification_model.dart';
import '../providers/notification_provider.dart';
import 'notifications_sheet.dart';

/// A delightful, floating drop-down notification banner that appears at the top
/// of the application when a real-time partner event, status change, or poke occurs.
class InAppNotificationBanner extends ConsumerStatefulWidget {
  final Widget child;

  const InAppNotificationBanner({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState
    extends ConsumerState<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  NotificationItem? _activeNotification;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _showBanner(NotificationItem item) {
    _dismissTimer?.cancel();
    HapticFeedback.mediumImpact();

    setState(() {
      _activeNotification = item;
    });

    _animController.forward(from: 0.0);

    // Auto-dismiss after 4.5 seconds
    _dismissTimer = Timer(const Duration(milliseconds: 4500), () {
      _dismissBanner();
    });
  }

  void _dismissBanner() {
    _dismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _activeNotification = null;
        });
        // Clear active banner provider
        ref.read(inAppNotificationBannerProvider.notifier).state = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for new in-app banner requests
    ref.listen<NotificationItem?>(
      inAppNotificationBannerProvider,
      (previous, next) {
        if (next != null) {
          _showBanner(next);
        }
      },
    );

    return Stack(
      children: [
        widget.child,
        if (_activeNotification != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Dismissible(
                    key: ValueKey(_activeNotification!.id),
                    direction: DismissDirection.up,
                    onDismissed: (_) => _dismissBanner(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space8,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _dismissBanner();
                            NotificationsSheet.show(context);
                          },
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusLg),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(AppTokens.radiusLg),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkDivider
                                    : AppColors.primary.withOpacity(0.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isDark ? 0.4 : 0.14),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.space16,
                              vertical: AppTokens.space12,
                            ),
                            child: Row(
                              children: [
                                // Mascot or Partner Avatar
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF2E3330)
                                        : const Color(0xFFE4EDE0),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const TogetherMascot(
                                    pose: MisoPose.wave,
                                    width: 38,
                                    height: 38,
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space12),
                                // Title & Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _activeNotification!.senderName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            '•  Just now',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _activeNotification!.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _activeNotification!.body,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppTokens.space8),
                                // Dismiss X button
                                IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18),
                                  color: Colors.grey,
                                  onPressed: _dismissBanner,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

