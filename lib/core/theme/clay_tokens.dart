import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ClaySurfaceType { raised, inset, flat, dock }

/// Precise dual-shadow physics and geometry tokens for Together's refined claymorphic visual language.
class ClayTokens {
  ClayTokens._();

  // ---------------------------------------------------------------------------
  // LIGHT CANVAS SHADOW TOKENS (#F8F6F0 Warm Cream)
  // ---------------------------------------------------------------------------

  /// Standard raised clay surface (cards, dialogs, buttons)
  static const List<BoxShadow> lightRaised = [
    // Top-left specular highlight
    BoxShadow(
      color: Color(0xFFFFFFFF),
      offset: Offset(-4, -4),
      blurRadius: 10,
      spreadRadius: 1,
    ),
    // Bottom-right soft ambient drop shadow
    BoxShadow(
      color: Color(0x33C8BFAF),
      offset: Offset(5, 7),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  /// High-elevation raised clay surface (floating action buttons, modal dialogs)
  static const List<BoxShadow> lightFloating = [
    BoxShadow(
      color: Color(0xFFFFFFFF),
      offset: Offset(-5, -5),
      blurRadius: 12,
      spreadRadius: 1,
    ),
    BoxShadow(
      color: Color(0x40B8AD9C),
      offset: Offset(7, 10),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Pressed / compressed state for raised clay
  static const List<BoxShadow> lightPressed = [
    BoxShadow(
      color: Color(0x99FFFFFF),
      offset: Offset(-1.5, -1.5),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color(0x24C8BFAF),
      offset: Offset(2, 3),
      blurRadius: 6,
    ),
  ];

  /// Inset / recessed groove borders & shadows (text inputs, search, unselected tracks)
  static const List<BoxShadow> lightInset = [
    BoxShadow(
      color: Color(0x2ED0C5B5),
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x80FFFFFF),
      offset: Offset(-2, -2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // ---------------------------------------------------------------------------
  // DARK CANVAS SHADOW TOKENS (#1F2220 Warm Charcoal)
  // ---------------------------------------------------------------------------

  /// Standard raised clay surface in dark mode
  static const List<BoxShadow> darkRaised = [
    // Top-left soft specular sheen
    BoxShadow(
      color: Color(0x2E4A564D),
      offset: Offset(-3, -3),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    // Bottom-right deep ambient shadow
    BoxShadow(
      color: Color(0x8C090C0A),
      offset: Offset(5, 7),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// High-elevation raised clay surface in dark mode
  static const List<BoxShadow> darkFloating = [
    BoxShadow(
      color: Color(0x384A564D),
      offset: Offset(-4, -4),
      blurRadius: 10,
    ),
    BoxShadow(
      color: Color(0xB3070908),
      offset: Offset(7, 10),
      blurRadius: 22,
    ),
  ];

  /// Pressed / compressed state for dark clay
  static const List<BoxShadow> darkPressed = [
    BoxShadow(
      color: Color(0x1F4A564D),
      offset: Offset(-1, -1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Color(0x66090C0A),
      offset: Offset(2, 3),
      blurRadius: 6,
    ),
  ];

  /// Inset / recessed groove in dark mode
  static const List<BoxShadow> darkInset = [
    BoxShadow(
      color: Color(0x99090C0A),
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: Color(0x1A4A564D),
      offset: Offset(-1, -1),
      blurRadius: 3,
    ),
  ];

  // ---------------------------------------------------------------------------
  // GRADIENT WASHES & SURFACE BACKGROUNDS
  // ---------------------------------------------------------------------------

  static LinearGradient lightRaisedGradient({Color? tintColor}) {
    final base = tintColor ?? AppColors.surface;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, Colors.white, 0.4)!,
        base,
        Color.lerp(base, const Color(0xFFEDE7DB), 0.25)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient darkRaisedGradient({Color? tintColor}) {
    final base = tintColor ?? AppColors.darkSurface;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, const Color(0xFF384039), 0.4)!,
        base,
        Color.lerp(base, const Color(0xFF1B1E1C), 0.35)!,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}

