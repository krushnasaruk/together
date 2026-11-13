import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import 'together_mascot.dart';

/// Speech bubble widget featuring Miso delivering contextual tips or warm greetings.
class MascotMessage extends StatelessWidget {
  final String message;
  final MisoPose pose;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MascotMessage({
    super.key,
    required this.message,
    this.pose = MisoPose.wave,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
            width: AppTokens.borderWidthThin,
          ),
          boxShadow: AppTokens.softShadow,
        ),
        child: Row(
          children: [
            TogetherMascot(
              pose: pose,
              height: 52,
              width: 52,
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppTokens.space8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A delightful, warm empty-state widget featuring Miso.
class MascotEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final MisoPose pose;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double mascotHeight;

  const MascotEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.pose = MisoPose.sleeping,
    this.actionLabel,
    this.onAction,
    this.mascotHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TogetherMascot(
              pose: pose,
              height: mascotHeight,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTokens.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.space20),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(140, 42),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A respectful, reassuring error state widget featuring Miso.
class MascotErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const MascotErrorState({
    super.key,
    this.title = 'A small hiccup occurred',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TogetherMascot(
              pose: MisoPose.reassuring,
              height: 96,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppTokens.space8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppTokens.space20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(140, 42),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
