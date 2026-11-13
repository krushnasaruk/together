import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Tier 1 Hero Panel: High-priority hero container with subtle gradient wash and soft elevation.
class HeroPanel extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const HeroPanel({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(AppTokens.space20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              accent.withOpacity(0.12),
              AppColors.darkSurface,
            ]
          : [
              accent.withOpacity(0.08),
              AppColors.surface,
            ],
    );

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.borderSubtle,
          width: AppTokens.borderWidthThin,
        ),
        boxShadow: AppTokens.softShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: content,
      );
    }

    return content;
  }
}
