import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../../shared/widgets/mascot/together_mascot.dart';
import '../guided_tour_step.dart';

/// Comic dialogue bubble styled after playful storybooks and companion UX.
/// Features a speech pointer tail, Miso mascot pose, step counter, and actions.
class ComicDialogueBubble extends StatelessWidget {
  final String title;
  final String message;
  final MisoPose pose;
  final int stepIndex;
  final int totalSteps;
  final SpeechPointerPosition pointerPosition;
  final double pointerTargetX;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onClose;

  const ComicDialogueBubble({
    super.key,
    required this.title,
    required this.message,
    required this.pose,
    required this.stepIndex,
    required this.totalSteps,
    required this.pointerPosition,
    this.pointerTargetX = 0.5,
    required this.onNext,
    required this.onPrevious,
    required this.onClose,
  });

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex >= totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor =
        isDark ? AppColors.darkDivider : AppColors.primary.withOpacity(0.3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upward pointing speech triangle if pointer is on TOP
        if (pointerPosition == SpeechPointerPosition.top)
          _buildPointer(
            isTop: true,
            color: backgroundColor,
            borderColor: borderColor,
          ),

        // Main speech card container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppTokens.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Mascot + Title + Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TogetherMascot(
                    pose: pose,
                    width: 52,
                    height: 52,
                    animateOnTap: true,
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Miso\'s Little Guide',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close / Dismiss X Button
                  Semantics(
                    button: true,
                    label: 'Close tour',
                    child: InkWell(
                      onTap: onClose,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isDark ? Colors.white10 : const Color(0xFFF0EFEA),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTokens.space16),

              // Body Message
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: AppTokens.space20),

              // Footer: Previous / Step Indicator / Next
              Row(
                children: [
                  // Previous or End Tour button
                  TextButton(
                    onPressed: isFirstStep ? onClose : onPrevious,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space12,
                        vertical: AppTokens.space8,
                      ),
                    ),
                    child: Text(
                      isFirstStep ? 'End Tour' : 'Previous',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Step indicator pill (e.g., "2/6")
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2E3330)
                          : const Color(0xFFF0EFEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stepIndex + 1} / $totalSteps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Next or Finish Button
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.space16,
                        vertical: AppTokens.space8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastStep ? 'Got it! ✨' : 'Next',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!isLastStep) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Downward pointing speech triangle if pointer is on BOTTOM
        if (pointerPosition == SpeechPointerPosition.bottom)
          _buildPointer(
            isTop: false,
            color: backgroundColor,
            borderColor: borderColor,
          ),
      ],
    );
  }

  Widget _buildPointer({
    required bool isTop,
    required Color color,
    required Color borderColor,
  }) {
    return Align(
      alignment: Alignment(pointerTargetX.clamp(-0.8, 0.8), 0.0),
      child: CustomPaint(
        size: const Size(20, 10),
        painter: _SpeechPointerPainter(
          isTop: isTop,
          fillColor: color,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _SpeechPointerPainter extends CustomPainter {
  final bool isTop;
  final Color fillColor;
  final Color borderColor;

  _SpeechPointerPainter({
    required this.isTop,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (isTop) {
      // Points upward
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      // Points downward
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeechPointerPainter oldDelegate) {
    return oldDelegate.isTop != isTop ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
