/// SafeReach Theme Configuration
/// Supports standard and high-contrast modes for accessibility
library;

import 'package:flutter/material.dart';

class SafeReachTheme {
  SafeReachTheme._();

  // ── Brand Colors ──────────────────────────────────────
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color primaryBlueDark = Color(0xFF0D2137);
  static const Color accentBlue = Color(0xFF4A90D9);
  static const Color sosRed = Color(0xFFE53E3E);
  static const Color sosRedDark = Color(0xFFC53030);
  static const Color safeGreen = Color(0xFF38A169);
  static const Color warningOrange = Color(0xFFED8936);
  static const Color warningYellow = Color(0xFFECC94B);
  static const Color surfaceLight = Color(0xFFF7FAFC);
  static const Color surfaceMedium = Color(0xFFEDF2F7);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);

  // ── Dark Theme Colors ─────────────────────────────────
  static const Color darkBg = Color(0xFF0F1724);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkSurfaceElevated = Color(0xFF243044);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ── High Contrast Colors ──────────────────────────────
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF1A1A1A);
  static const Color hcText = Color(0xFFFFFFFF);
  static const Color hcHighlight = Color(0xFFFFD700);
  static const Color hcSosRed = Color(0xFFFF0000);
  static const Color hcBorder = Color(0xFFFFFFFF);

  // ── Location Badge Colors ─────────────────────────────
  static const Color locationLiveGPS = Color(0xFF38A169);
  static const Color locationApproximate = Color(0xFFECC94B);
  static const Color locationLastKnown = Color(0xFFED8936);
  static const Color locationManual = Color(0xFF4A90D9);

  // ── Incident Status Colors ────────────────────────────
  static const Color statusCreated = Color(0xFF4A90D9);
  static const Color statusSent = Color(0xFFED8936);
  static const Color statusDelivered = Color(0xFFECC94B);
  static const Color statusAcknowledged = Color(0xFF38A169);
  static const Color statusOnTheWay = Color(0xFF38A169);
  static const Color statusResolved = Color(0xFF2D7D46);
  static const Color statusCancelled = Color(0xFF718096);
  static const Color statusFalseAlert = Color(0xFFA0AEC0);

  // ── Standard Light Theme ──────────────────────────────
  static ThemeData lightTheme({double fontScale = 1.0}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: accentBlue,
        error: sosRed,
        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 16 * fontScale),
        hintStyle: TextStyle(fontSize: 14 * fontScale, color: textSecondary),
      ),
      textTheme: _buildTextTheme(fontScale, textPrimary, textSecondary),
      iconTheme: const IconThemeData(color: primaryBlue, size: 24),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryBlueDark,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14 * fontScale,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Standard Dark Theme ───────────────────────────────
  static ThemeData darkTheme({double fontScale = 1.0}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentBlue,
        brightness: Brightness.dark,
        primary: accentBlue,
        secondary: primaryBlue,
        error: sosRed,
        surface: darkSurface,
      ),
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkSurfaceElevated,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 16 * fontScale, color: darkTextSecondary),
      ),
      textTheme: _buildTextTheme(fontScale, darkTextPrimary, darkTextSecondary),
      iconTheme: const IconThemeData(color: accentBlue, size: 24),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── High Contrast Theme (Accessibility) ───────────────
  static ThemeData highContrastTheme({double fontScale = 1.0}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: hcHighlight,
        secondary: hcHighlight,
        error: hcSosRed,
        surface: hcSurface,
        onPrimary: hcBackground,
        onSecondary: hcBackground,
        onSurface: hcText,
        onError: hcText,
      ),
      scaffoldBackgroundColor: hcBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: hcBackground,
        foregroundColor: hcText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22 * fontScale,
          fontWeight: FontWeight.w700,
          color: hcText,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: hcBorder, width: 2),
        ),
        color: hcSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(64, 64),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          backgroundColor: hcHighlight,
          foregroundColor: hcBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: hcBorder, width: 2),
          ),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 64),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          foregroundColor: hcText,
          side: const BorderSide(color: hcBorder, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: hcSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hcBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hcBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hcHighlight, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        labelStyle: TextStyle(fontSize: 18 * fontScale, color: hcHighlight),
        hintStyle: TextStyle(fontSize: 16 * fontScale, color: hcText.withValues(alpha: 0.7)),
      ),
      textTheme: _buildTextTheme(fontScale * 1.15, hcText, hcText.withValues(alpha: 0.85)),
      iconTheme: const IconThemeData(color: hcHighlight, size: 28),
      dividerTheme: const DividerThemeData(color: hcBorder, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: hcSurface,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16 * fontScale,
          fontWeight: FontWeight.w600,
          color: hcText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: hcBorder, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Text Theme Builder ────────────────────────────────
  static TextTheme _buildTextTheme(double scale, Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32 * scale, fontWeight: FontWeight.w700, color: primary),
      displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 28 * scale, fontWeight: FontWeight.w700, color: primary),
      displaySmall: TextStyle(fontFamily: 'Inter', fontSize: 24 * scale, fontWeight: FontWeight.w600, color: primary),
      headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 22 * scale, fontWeight: FontWeight.w600, color: primary),
      headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 20 * scale, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: TextStyle(fontFamily: 'Inter', fontSize: 18 * scale, fontWeight: FontWeight.w600, color: primary),
      titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 18 * scale, fontWeight: FontWeight.w600, color: primary),
      titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16 * scale, fontWeight: FontWeight.w500, color: primary),
      titleSmall: TextStyle(fontFamily: 'Inter', fontSize: 14 * scale, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16 * scale, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14 * scale, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12 * scale, fontWeight: FontWeight.w400, color: secondary),
      labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 16 * scale, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 14 * scale, fontWeight: FontWeight.w500, color: primary),
      labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12 * scale, fontWeight: FontWeight.w500, color: secondary),
    );
  }
}
