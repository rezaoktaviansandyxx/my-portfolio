import 'package:flutter/material.dart';

/// Turunan warna stabil dari nama skill: nama yang sama selalu dapat
/// gradient yang sama, tanpa perlu menyimpan warna di backend.
LinearGradient skillGradient(String name) {
  final key = name.trim().toLowerCase();
  var hash = 0;
  for (final unit in key.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  final hue = (hash % 360).toDouble();
  final start = HSLColor.fromAHSL(1, hue, 0.72, 0.58).toColor();
  final end = HSLColor.fromAHSL(1, (hue + 42) % 360, 0.78, 0.46).toColor();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [start, end],
  );
}
