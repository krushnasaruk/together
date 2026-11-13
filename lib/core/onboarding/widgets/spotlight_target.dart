import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Custom painter rendering a dark scrim with a rounded rectangular cutout
/// over the active target and an animated glowing focus pulse.
class SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double pulseValue;
  final Color scrimColor;
  final Color focusColor;
  final double cornerRadius;
  final double padding;

  SpotlightPainter({
    required this.targetRect,
    required this.pulseValue,
    this.scrimColor = const Color(0x9E000000),
    this.focusColor = AppColors.primary,
    this.cornerRadius = 16.0,
    this.padding = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final screenRect = Offset.zero & size;

    if (targetRect == null) {
      // No spotlight cutout: uniform modal backdrop
      final paint = Paint()..color = scrimColor;
      canvas.drawRect(screenRect, paint);
      return;
    }

    final inflatedRect = targetRect!.inflate(padding);
    final cutoutRRect = RRect.fromRectAndRadius(
      inflatedRect,
      Radius.circular(cornerRadius),
    );

    // 1. Draw scrim with transparent cutout hole using Path.combine
    final path = Path()
      ..addRect(screenRect)
      ..addRRect(cutoutRRect)
      ..fillType = PathFillType.evenOdd;

    final scrimPaint = Paint()
      ..color = scrimColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, scrimPaint);

    // 2. Draw animated glowing pulse border around cutout
    final pulseOffset = 2.0 * pulseValue;
    final pulseRRect = RRect.fromRectAndRadius(
      inflatedRect.inflate(pulseOffset),
      Radius.circular(cornerRadius + pulseOffset),
    );

    final glowPaint = Paint()
      ..color = focusColor.withOpacity(0.7 - (0.4 * pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(pulseRRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.scrimColor != scrimColor;
  }
}
