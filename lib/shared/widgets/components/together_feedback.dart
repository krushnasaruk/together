import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../mascot/together_mascot.dart';
import 'together_buttons.dart';

/// Centralized user feedback tools (Toasts, Dialogs, Bottom Sheets).
class TogetherFeedback {
  TogetherFeedback._();

  /// Show a playful, friendly toast notification featuring Miso.
  static void showToast(
    BuildContext context, {
    required String message,
    MisoPose pose = MisoPose.happy,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(AppTokens.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        content: Row(
          children: [
            TogetherMascot(
              pose: pose,
              height: 36,
              width: 36,
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a confirmation or information dialog with Miso's presence.
  static Future<bool?> showDialog(
    BuildContext context, {
    required String title,
    required String message,
    MisoPose? pose,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            side: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
            ),
          ),
          title: Row(
            children: [
              if (pose != null) ...[
                TogetherMascot(pose: pose, height: 44, width: 44),
                const SizedBox(width: AppTokens.space12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.45,
                ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                cancelLabel,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TogetherButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(ctx).pop(true),
              variant: isDestructive
                  ? TogetherButtonVariant.danger
                  : TogetherButtonVariant.primary,
              height: 38,
            ),
          ],
        );
      },
    );
  }

  /// Show a standardized bottom sheet.
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusXl),
          ),
          boxShadow: AppTokens.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTokens.space8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).brightness == Brightness.dark
                    ? AppColors.darkDivider
                    : AppColors.borderMedium,
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              ),
            ),
            Flexible(child: builder(ctx)),
          ],
        ),
      ),
    );
  }
}
