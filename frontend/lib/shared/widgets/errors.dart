import 'package:frontend/services/api_service.dart';

/// Pesan error ramah berbasis [ApiException.statusCode] (404/429),
/// tanpa dump `$e` mentah ke pengguna.
String friendlyError(Object e, String fallback) {
  if (e is ApiException) {
    if (e.isNotFound) {
      return 'Data tidak ditemukan. Muat ulang lalu coba lagi.';
    }
    if (e.isRateLimited) {
      return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
    }
    return e.message;
  }
  return fallback;
}
