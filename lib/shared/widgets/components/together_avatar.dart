import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Reusable avatar widget for users and partner badges.
class TogetherAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final Color? borderColor;
  final Color? backgroundColor;

  const TogetherAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40.0,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'M';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget avatarContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(initial, isDark),
        ),
      );
    } else {
      avatarContent = _buildFallback(initial, isDark);
    }

    if (borderColor != null) {
      return Container(
        width: size + 4,
        height: size + 4,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: 2),
        ),
        child: avatarContent,
      );
    }

    return SizedBox(width: size, height: size, child: avatarContent);
  }

  Widget _buildFallback(String initial, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? const Color(0xFF3B443D) : const Color(0xFFE8EFE8)),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: isDark ? AppColors.darkPrimary : AppColors.primaryDark,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
