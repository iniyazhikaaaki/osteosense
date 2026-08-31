// lib/theme/app_theme.dart
// Modern Project-Winning Medical Design System for OsteoSense

import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color electricTeal = Color(0xFF0D9488);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color backgroundIce = Color(0xFFF8FAFC);
  static const Color cardSurface = Colors.white;

  // Chart Line Colors matching reference screenshot
  static const Color leftKneeDarkBlue = Color(0xFF0B4F9C);
  static const Color rightKneeLightBlue = Color(0xFF38BDF8);

  // Risk Band Colors
  static const Color riskLowBg = Color(0xFFECFDF5);
  static const Color riskLowText = Color(0xFF047857);
  static const Color riskLowBorder = Color(0xFF6EE7B7);

  static const Color riskModerateBg = Color(0xFFFFFBEB);
  static const Color riskModerateText = Color(0xFFB45309);
  static const Color riskModerateBorder = Color(0xFFFCD34D);

  static const Color riskHighBg = Color(0xFFFFF7ED);
  static const Color riskHighText = Color(0xFFC2410C);
  static const Color riskHighBorder = Color(0xFFFDBA74);

  static const Color riskExtremeBg = Color(0xFFFEF2F2);
  static const Color riskExtremeText = Color(0xFFB91C1C);
  static const Color riskExtremeBorder = Color(0xFFFCA5A5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: electricTeal,
        primary: electricTeal,
        secondary: accentCyan,
        surface: cardSurface,
        background: backgroundIce,
      ),
      scaffoldBackgroundColor: backgroundIce,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricTeal,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
