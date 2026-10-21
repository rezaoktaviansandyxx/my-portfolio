import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/password_visibility.dart';

/// Field FolioSpace: dekorasi memakai [InputDecorationTheme] global
/// (radius 14, fill lembut, border halus) sehingga tampil seragam di
/// seluruh dashboard dan dialog, termasuk mode gelap.
///
/// Untuk field password pakai [folioPasswordField] — field ini sengaja
/// tidak punya opsi `obscureText` supaya tidak ada password field yang
/// ter-sembunyikan tanpa tombol mata.
Widget folioField(
  TextEditingController c,
  String label, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboard,
  IconData? icon,
  String? prefixText,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
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

/// Versi [folioField] untuk password: ada tombol mata untuk menampilkan atau
/// menyembunyikan isi. Dekorasi dan paddingnya sama persis dengan
/// [folioField] supaya seragam dengan field lain.
Widget folioPasswordField(
  TextEditingController c,
  String label, {
  String? hint,
  IconData? icon,
}) {
  return FolioPasswordField(
    controller: c,
    label: label,
    hint: hint,
    icon: icon,
  );
}

/// State-nya dipegang [FolioPasswordField] supaya status "terlihat atau
/// tersembunyi" tetap hidup saat widget di-rebuild oleh induknya.
class FolioPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;

  const FolioPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
  });

  @override
  State<FolioPasswordField> createState() => _FolioPasswordFieldState();
}

class _FolioPasswordFieldState extends State<FolioPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: widget.controller,
        maxLines: 1,
        obscureText: !_visible,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          isDense: true,
          prefixIcon: widget.icon != null ? Icon(widget.icon, size: 18) : null,
          suffixIcon: PasswordVisibilityButton(
            visible: _visible,
            onPressed: () => setState(() => _visible = !_visible),
          ),
        ),
      ),
    );
  }
}
