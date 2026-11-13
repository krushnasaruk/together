import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/clay_tokens.dart';
import '../mascot/together_mascot.dart';
import 'clay_button.dart';

/// Modal dialog styled with Together's refined claymorphic aesthetic.
class TogetherDialog {
  TogetherDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    MisoPose? pose,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(AppTokens.space24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              boxShadow:
                  isDark ? ClayTokens.darkFloating : ClayTokens.lightFloating,
              border: Border.all(
                color:
                    isDark ? const Color(0x334A564D) : const Color(0x80FFFFFF),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (pose != null) ...[
                  TogetherMascot(
                    pose: pose,
                    height: 72,
                    width: 72,
                    animateOnTap: true,
                  ),
                  const SizedBox(height: AppTokens.space16),
                ],
                Text(
                  title,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.space10),
                Text(
                  message,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        height: 1.45,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.space24),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        label: cancelLabel,
                        variant: ClayButtonVariant.secondary,
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space12),
                    Expanded(
                      child: ClayButton(
                        label: confirmLabel,
                        variant: isDestructive
                            ? ClayButtonVariant.danger
                            : ClayButtonVariant.primary,
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
