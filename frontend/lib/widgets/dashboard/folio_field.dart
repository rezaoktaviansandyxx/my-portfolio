import 'package:flutter/material.dart';

Widget folioField(
  TextEditingController c,
  String label, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboard,
  bool obscureText = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: c,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboard,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    ),
  );
}
