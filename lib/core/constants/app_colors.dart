import 'package:flutter/material.dart';

/// Central color palette tokens for the Together application.
/// Embodies a warm, human, minimal, mature and personal aesthetic.
class AppColors {
  AppColors._();

  // Background and Canvas
  static const Color background = Color(0xFFFBF9F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF4EFE6);
  static const Color surfaceElevated = Color(0xFFFCFAF7);

  // Partner Theme Accents
  // Partner A: Muted Sage Green
  static const Color partnerSage = Color(0xFF4D6A56);
  static const Color partnerSageDark = Color(0xFF374D3E);
  static const Color partnerSageLight = Color(0xFFE8EFEA);

  // Partner B: Dusty Rose
  static const Color partnerRose = Color(0xFFA45D5D);
  static const Color partnerRoseDark = Color(0xFF7D4343);
  static const Color partnerRoseLight = Color(0xFFF8ECEC);

  // Shared Together Accent: Muted Slate / Dusty Blue
  static const Color togetherBlue = Color(0xFF556F7A);
  static const Color togetherBlueLight = Color(0xFFEAEFF2);

  // Text Colors
  static const Color textPrimary = Color(0xFF2B2E2B);
  static const Color textSecondary = Color(0xFF6B726C);
  static const Color textTertiary = Color(0xFF9EA39F);
  static const Color textInverse = Color(0xFFFAF9F6);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFE8E3DA);
  static const Color borderMedium = Color(0xFFD4CEC3);

  // Semantic Event Status Colors
  static const Color statusConfirmed = Color(0xFF437654);
  static const Color statusTentative = Color(0xFFB87832);
  static const Color statusCancelled = Color(0xFFA84A4A);
  static const Color statusCompleted = Color(0xFF5A6B5D);

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
