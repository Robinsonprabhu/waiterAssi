// ===========================================================================
// core/app_theme.dart
// Centralized theme for the entire app.
// High contrast, large text — optimized for fast-paced restaurant use.
// ===========================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // --- Brand Colors ---
  static const Color primaryOrange = Color(0xFFE65100);   // Deep saffron-orange
  static const Color accentGold    = Color(0xFFFFA000);   // Warm amber
  static const Color kitchenGreen  = Color(0xFF1B5E20);   // Deep kitchen green
  static const Color readyGreen    = Color(0xFF2E7D32);
  static const Color pendingAmber  = Color(0xFFFF6F00);
  static const Color darkBg        = Color(0xFF1A1A1A);
  static const Color cardBg        = Color(0xFF2C2C2C);
  static const Color surfaceGrey   = Color(0xFF3A3A3A);
  static const Color textPrimary   = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color divider       = Color(0xFF444444);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.dark(
      primary: primaryOrange,
      secondary: accentGold,
      surface: cardBg,
      onPrimary: Colors.white,
      onSurface: textPrimary,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111111),
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44), // Constraint: all buttons min 44px tall
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(0),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
    ),
  );
}
