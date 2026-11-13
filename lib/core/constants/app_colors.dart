import 'package:flutter/material.dart';

/// Central color palette tokens for the Together application.
/// Embodies a playful, expressive, warm, clean, hand-drawn and friendly aesthetic.
/// Built around the Miso visual identity.
class AppColors {
  AppColors._();

  // --- Light Palette Tokens ---
  static const Color background = Color(0xFFF8F6F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFA8B99F); // Muted Sage
  static const Color primaryDark = Color(0xFF536B54);
  static const Color secondary = Color(0xFFE8B9B0); // Subdued Rose
  static const Color accentBlue = Color(0xFFC4D8DF);
  static const Color lavender = Color(0xFFD8CEE5);
  static const Color sand = Color(0xFFE8DDCA);
  static const Color textPrimary = Color(0xFF343A36);
  static const Color textSecondary = Color(0xFF85877F);
  static const Color divider = Color(0xFFE8E5DC);
  static const Color error = Color(0xFFD96B6B);
  static const Color success = Color(0xFF609966);

  // Surface variations
  static const Color surfaceSecondary = Color(0xFFF2ECE1);
  static const Color surfaceElevated = Color(0xFFFCFAF6);

  // --- Dark Palette Tokens ---
  static const Color darkBackground = Color(0xFF1F2220); // Warm charcoal
  static const Color darkSurface = Color(0xFF2A2E2B); // Lighter charcoal
  static const Color darkPrimary = Color(0xFF8EA885);
  static const Color darkSecondary = Color(0xFFD99B90);
  static const Color darkTextPrimary = Color(0xFFF0EFEA);
  static const Color darkTextSecondary = Color(0xFFA5A9A4);
  static const Color darkDivider = Color(0xFF3A3F3B);

  // --- Partner Theme Accents (Continuity & Distinction) ---
  // Partner A: Muted Sage Green
  static const Color partnerSage = Color(0xFF536B54);
  static const Color partnerSageDark = Color(0xFF3B4D3C);
  static const Color partnerSageLight = Color(0xFFE8EFE8);

  // Partner B: Dusty Rose
  static const Color partnerRose = Color(0xFFA45D5D);
  static const Color partnerRoseDark = Color(0xFF7D4343);
  static const Color partnerRoseLight = Color(0xFFF8ECEC);

  // Shared Together Accent: Muted Slate / Dusty Blue
  static const Color togetherBlue = Color(0xFF556F7A);
  static const Color togetherBlueLight = Color(0xFFEAEFF2);

  // Text Inversion & Accents
  static const Color textTertiary = Color(0xFF9EA39F);
  static const Color textInverse = Color(0xFFFAF9F6);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE8E5DC);
  static const Color borderMedium = Color(0xFFD6D1C6);

  // Semantic Event Status Colors
  static const Color statusConfirmed = Color(0xFF609966);
  static const Color statusTentative = Color(0xFFD49B4B);
  static const Color statusCancelled = Color(0xFFD96B6B);
  static const Color statusCompleted = Color(0xFF6E8B75);

  // Category Colors
  static const Color categoryWork = Color(0xFF596E79);
  static const Color categoryCollege = Color(0xFF786588);
  static const Color categoryStudy = Color(0xFF5E7569);
  static const Color categoryPersonal = Color(0xFF966C56);
  static const Color categoryFamily = Color(0xFF9E6472);
  static const Color categorySocial = Color(0xFF867252);
  static const Color categoryTravel = Color(0xFF4C7B80);
  static const Color categoryOther = Color(0xFF707775);
}
