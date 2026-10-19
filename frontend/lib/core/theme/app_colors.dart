import 'package:flutter/material.dart';

/// Token warna tunggal untuk seluruh aplikasi (dark only).
class AppColors {
  AppColors._();

  // Latar
  static const bg = Color(0xFF060A18);
  static const bgAlt = Color(0xFF0B1024);

  // Brand
  static const violet = Color(0xFF7C3AED);
  static const indigo = Color(0xFF4F46E5);
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF22D3EE);

  // Teks
  static const ink = Color(0xFFEDF1FB);
  static const body = Color(0xFFAEBAD4);
  static const muted = Color(0xFF93A0BD);

  // Status
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  // Glass
  static const glassFill = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
  static const glassBorderStrong = Color(0x2EFFFFFF);

  // Varian lembut (konstanta agar tetap bisa dipakai di const context)
  static const indigoSoft = Color(0x2E4F46E5);
  static const successSoft = Color(0x2434D399);
  static const warningSoft = Color(0x24FBBF24);
  static const dangerSoft = Color(0x24F87171);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [violet, indigo, blue],
  );

  static const cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, blue],
  );
}
