/// Satu sumber untuk pola validasi yang dipakai lintas layar.
///
/// Dulu regex ini di-copy-paste di `register_screen`, `contact_section`,
/// dan `dashboard_dialogs` — rawan meleset saat satu sisi diubah tapi
/// sisi lain tidak.
library;

/// Username: lowercase, angka, underscore; 3-30 karakter (sama dengan
/// batas di backend `RegisterRequest`).
final RegExp kUsernamePattern = RegExp(r'^[a-z0-9_]{3,30}$');

/// Email gaya sederhana (validasi penuh tetap di backend).
final RegExp kEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Slug: lowercase-hyphen, tanpa hyphen di tepi maupun dobel.
final RegExp kSlugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

final RegExp _whitespace = RegExp(r'\s+');

/// Inisial nama untuk avatar fallback: kata pertama setelah whitespace
/// dilucuti (semantik yang selama ini dipakai semua call site).
String firstWordOf(String name) {
  final parts = name.trim().split(_whitespace).where((p) => p.isNotEmpty);
  return parts.isEmpty ? '' : parts.first;
}

/// Inisial (maksimal [maxWords] huruf) dari kata-kata nama, dikapitalisasi.
/// [fallback] dikembalikan kalau nama hanya whitespace.
String initialsOf(
  String name, {
  int maxWords = 2,
  String fallback = '?',
}) {
  final parts = name
      .trim()
      .split(_whitespace)
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return fallback;
  return parts.take(maxWords).map((p) => p[0].toUpperCase()).join();
}
