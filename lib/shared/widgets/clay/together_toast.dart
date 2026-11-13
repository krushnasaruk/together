import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/clay_tokens.dart';
import '../mascot/together_mascot.dart';

/// Floating clay toast notification with directional lighting and Miso companion presence.
class TogetherToast {
  TogetherToast._();

  static void show(
    BuildContext context, {
    required String message,
    MisoPose pose = MisoPose.happy,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            boxShadow:
                isDark ? ClayTokens.darkFloating : ClayTokens.lightFloating,
            border: Border.all(
              color: isDark ? const Color(0x334A564D) : const Color(0x66FFFFFF),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              TogetherMascot(
                pose: pose,
                height: 36,
                width: 36,
                animateOnTap: true,
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
