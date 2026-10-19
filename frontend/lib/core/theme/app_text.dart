import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Skala tipografi. Ukuran responsif ditangani pemanggil lewat `copyWith`.
class AppText {
  AppText._();

  static const display = TextStyle(
    fontSize: 44,
    height: 1.08,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.2,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontSize: 26,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 14.5,
    height: 1.6,
    color: AppColors.body,
  );

  static const label = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const caption = TextStyle(
    fontSize: 11.5,
    color: AppColors.muted,
  );

  /// Eyebrow kapital di atas judul section.
  static const eyebrow = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.6,
    color: AppColors.cyan,
  );
}
