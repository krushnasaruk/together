import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_tokens.dart';

/// Tactile clay toggle switch with recessed track and raised sliding pill.
class ClayToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const ClayToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        activeColor ?? (isDark ? AppColors.darkPrimary : AppColors.primaryDark);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value
              ? primary.withOpacity(isDark ? 0.4 : 0.25)
              : (isDark ? const Color(0xFF191C1A) : const Color(0xFFEBE5DA)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? ClayTokens.darkInset : ClayTokens.lightInset,
          border: Border.all(
            color: value
                ? primary.withOpacity(0.5)
                : (isDark ? Colors.white10 : Colors.black12),
            width: 1.0,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? primary
                  : (isDark ? const Color(0xFF384039) : Colors.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
