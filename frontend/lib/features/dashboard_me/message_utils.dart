/// Helper pesan inbox yang aman terhadap data server yang tidak lengkap.
///
/// Dulu, admin dashboard meng-crash `RangeError` saat `sender_name` kosong
/// (`''.substring(0, 1)`) dan cast keras `(m['id'] as num)` — server yang
/// mengirim data janggal tidak boleh menjatuhkan UI.
library;

/// Huruf pertama avatar inisial; `?` bila nama kosong.
String messageInitial(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty) return '?';
  return trimmed[0].toUpperCase();
}

/// Ambient parse id pesan dari payload server; null bila tidak valid.
int? parseMessageId(dynamic raw) {
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw);
  return null;
}
