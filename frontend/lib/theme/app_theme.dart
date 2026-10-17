import 'package:flutter/material.dart';

/// Palet warna FolioSpace (mode terang).
/// Indigo sebagai warna utama, aksen mint/peach sebagai pendukung,
/// netral hangat agar halaman tidak terlihat "abu-abu hambar".
class FolioColors {
  // Permukaan & garis
  static const bg = Color(0xFFF7F8FC);
  static const card = Colors.white;
  static const border = Color(0xFFE5E8F0);

  // Teks
  static const ink = Color(0xFF171A2C);
  static const body = Color(0xFF3E4459);
  static const muted = Color(0xFF5B6172);

  // Warna utama (indigo)
  static const primary = Color(0xFF4F46E5);
  static const primaryDeep = Color(0xFF3730A3);
  static const primarySoft = Color(0xFFEDEBFF);

  // Sidebar gelap shell dashboard (top→bottom gradient halus)
  static const sbBgTop = Color(0xFF1B1E33);
  static const sbBgBottom = Color(0xFF13161F);
  static const sbText = Color(0xFF9BA2BA);
  static const sbMuted = Color(0xFF6E7590);
  static const sbBadge = Color(0x29FFFFFF); // putih ~16%
  static const sbBorder = Color(0x14FFFFFF); // putih ~8%

  // Aksen pendukung
  static const greenBg = Color(0xFFE2F7EC);
  static const green = Color(0xFF0E9F6E);
  static const peachBg = Color(0xFFFFF0DE);
  static const peachInk = Color(0xFFAD4E00);
  static const lilacBg = Color(0xFFF0EEFE);
  static const mintBg = Color(0xFFE2F7EC);
  static const orangeBg = Color(0xFFFFF0DE);
}

/// Padanan gelap untuk mode gelap (themeMode: system).
class FolioDarkColors {
  static const bg = Color(0xFF12131F);
  static const card = Color(0xFF1A1C2B);
  static const border = Color(0xFF2A2E44);

  static const ink = Color(0xFFF1F2F8);
  static const body = Color(0xFFC6CAD9);
  static const muted = Color(0xFF9BA1B3);

  static const primary = Color(0xFF918AFB);
  static const primaryDeep = Color(0xFF6D63F0);
  static const primarySoft = Color(0xFF262A44);

  // Sidebar gelap shell dashboard (mode gelap: tumpuk lebih pekat)
  static const sbBgTop = Color(0xFF181A2B);
  static const sbBgBottom = Color(0xFF10111A);
  static const sbText = Color(0xFF8F95A8);
  static const sbMuted = Color(0xFF6E7590);
  static const sbBadge = Color(0x29FFFFFF);
  static const sbBorder = Color(0x14FFFFFF);

  static const greenBg = Color(0xFF15301F);
  static const green = Color(0xFF34D399);
  static const peachBg = Color(0xFF372510);
  static const peachInk = Color(0xFFFDBA74);
  static const lilacBg = Color(0xFF262A44);
  static const mintBg = Color(0xFF15301F);
  static const orangeBg = Color(0xFF372510);
}

class AppTheme {
  AppTheme._();

  static const _radiusCard = 20.0;
  static const _radiusField = 14.0;

  static ThemeData get lightTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: FolioColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: FolioColors.primary,
          surface: FolioColors.card,
          outline: FolioColors.border,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FolioColors.bg,
      textTheme: Typography.material2021().black.apply(
        bodyColor: FolioColors.ink,
        displayColor: FolioColors.ink,
      ),
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
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: FolioColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F5FA),
        labelStyle: const TextStyle(color: FolioColors.muted, fontSize: 14),
        hintStyle: const TextStyle(
          color: Color(0xFFA6ACBE),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(color: FolioColors.primary),
        prefixIconColor: const Color(0xFF8A91A5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFFE7EAF2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: FolioColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: FolioColors.primarySoft,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        labelStyle: TextStyle(
          color: FolioColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FolioColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FolioColors.primary,
          side: const BorderSide(color: Color(0xFFD8DCE8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          color: FolioColors.ink,
          fontSize: 13.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FolioColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: FolioColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: FolioDarkColors.primary,
          surface: FolioDarkColors.card,
          outline: FolioDarkColors.border,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FolioDarkColors.bg,
      textTheme: Typography.material2021().white.apply(
        bodyColor: FolioDarkColors.ink,
        displayColor: FolioDarkColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: FolioDarkColors.card,
        foregroundColor: FolioDarkColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: FolioDarkColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusCard),
          side: const BorderSide(color: FolioDarkColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF202336),
        labelStyle: const TextStyle(color: FolioDarkColors.muted, fontSize: 14),
        hintStyle: const TextStyle(
          color: FolioDarkColors.muted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(color: FolioDarkColors.primary),
        prefixIconColor: FolioDarkColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFF2C3047)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(
            color: FolioDarkColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusField),
          borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: FolioDarkColors.primarySoft,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(9)),
        ),
        labelStyle: TextStyle(
          color: FolioDarkColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FolioDarkColors.primary,
          foregroundColor: const Color(0xFF16182B),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FolioDarkColors.primary,
          side: const BorderSide(color: FolioDarkColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF23253A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(
          color: FolioDarkColors.ink,
          fontSize: 13.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FolioDarkColors.border,
        thickness: 1,
      ),
    );
  }
}
