import 'package:flutter/material.dart';

/// Centralized motion tokens and physics specifications for Together.
class TogetherMotion {
  TogetherMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration counter = Duration(milliseconds: 1200);

  // Easing Curves
  static const Curve spring = Curves.easeOutBack;
  static const Curve smoothOut = Curves.easeOutCubic;
  static const Curve smoothInOut = Curves.easeInOutCubic;

  // Stagger intervals
  static const Duration staggerItem = Duration(milliseconds: 45);

  /// Respects user's system reduced motion setting
  static Duration duration(BuildContext context, Duration baseDuration) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Duration.zero;
    }
    return baseDuration;
  }
}

