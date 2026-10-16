import 'package:flutter/material.dart';

class FolioColors {
  static const bg = Color(0xFFF4F5F9);
  static const card = Colors.white;
  static const border = Color(0xFFE8EAF1);
  static const ink = Color(0xFF14142B);
  static const muted = Color(0xFF6B7280);
  static const primary = Color(0xFF6C5CFF);
  static const primarySoft = Color(0xFFEFEFFF);
  static const greenBg = Color(0xFFE6F7ED);
  static const green = Color(0xFF12A56B);
  static const peachBg = Color(0xFFFFE9D6);
  static const peachInk = Color(0xFF9A4A0A);
  static const lilacBg = Color(0xFFF1EAFE);
  static const mintBg = Color(0xFFE6F9F0);
  static const orangeBg = Color(0xFFFFF0E0);
}

class AppTheme {
  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: FolioColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: FolioColors.primary,
      surface: FolioColors.card,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FolioColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: FolioColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: FolioColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF7F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FolioColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: FolioColors.border),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F2F7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: FolioColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
