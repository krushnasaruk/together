import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Tier 4 Interactive Action Card: Clickable setting or feature card with icon container, titles, and trailing widget.
class ActionCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? leadingColor;
  final EdgeInsets padding;

  const ActionCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.leadingColor,
    this.padding = const EdgeInsets.all(AppTokens.space16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      padding: padding,
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
          if (leading != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTokens.space10),
              decoration: BoxDecoration(
                color: leadingColor?.withOpacity(0.14) ??
                    (isDark
                        ? const Color(0xFF38443A)
                        : const Color(0xFFE8EFE8)),
                shape: BoxShape.circle,
              ),
              child: leading!,
            ),
            const SizedBox(width: AppTokens.space14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTokens.space12),
            trailing!,
          ] else if (onTap != null) ...[
            Icon(
              Icons.chevron_right_rounded,
              size: AppTokens.iconLg,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: content,
      );
    }

    return content;
  }
}
