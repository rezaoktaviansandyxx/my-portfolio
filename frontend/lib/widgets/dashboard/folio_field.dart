import 'package:flutter/material.dart';

/// Field FolioSpace: dekorasi memakai [InputDecorationTheme] global
/// (radius 14, fill lembut, border halus) sehingga tampil seragam di
/// seluruh dashboard dan dialog, termasuk mode gelap.
Widget folioField(
  TextEditingController c,
  String label, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboard,
  bool obscureText = false,
  IconData? icon,
  String? prefixText,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboard,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        prefixText: (prefixText == null || prefixText.isEmpty)
            ? null
            : prefixText,
        prefixStyle: const TextStyle(
          color: Color(0xFF8A91A5),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
