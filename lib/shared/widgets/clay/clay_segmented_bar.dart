import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/clay_tokens.dart';

/// Recessed track segmented bar with a raised sliding clay pill indicator.
class ClaySegmentedBar<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const ClaySegmentedBar({
    super.key,
    required this.values,
    required this.labels,
    required this.selectedValue,
    required this.onSelected,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.darkPrimary : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A18) : const Color(0xFFEFE8DD),
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        boxShadow: isDark ? ClayTokens.darkInset : ClayTokens.lightInset,
        border: Border.all(
          color: isDark ? const Color(0x2E4A564D) : const Color(0x38FFFFFF),
          width: 1.0,
        ),
      ),
      child: Row(
        children: List.generate(values.length, (index) {
          final val = values[index];
          final label = labels[index];
          final isSelected = val == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  onSelected(val);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2E3831) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  boxShadow: isSelected
                      ? (isDark
                          ? ClayTokens.darkPressed
                          : ClayTokens.lightPressed)
                      : const [],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
