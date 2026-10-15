import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4F46E5);    // Deep Indigo
  static const secondary = Color(0xFF7C3AED);  // Electric Violet
  static const tertiary = Color(0xFFD97706);   // Sparkle Gold / Sunday
  static const lightBg = Color(0xFFF8FAFC);    // Slate 50
  static const darkBg = Color(0xFF0F172A);     // Slate 900
  static const darkSurface = Color(0xFF1E293B); // Slate 800
  static const success = Color(0xFF16A34A);    // Green 600
  static const info = Color(0xFF2563EB);       // Blue 600
  static const warning = Color(0xFFEAB308);    // Yellow 500
  static const danger = Color(0xFFDC2626);     // Red 600
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.lightBg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8), // Lighter indigo for dark mode
      secondary: const Color(0xFFA78BFA),
      tertiary: const Color(0xFFFBBF24), // Vibrant gold
      surface: AppColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white10),
        ),
      ),
    );
  }
}