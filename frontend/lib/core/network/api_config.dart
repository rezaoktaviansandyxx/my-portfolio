import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  /// Fallback saat `.env` tidak ada (mis. build CI atau clone baru).
  static const defaultApiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  /// Membaca `.env` ke dotenv; panggil sekali sebelum [ApiConfig.baseUrl]
  /// dipakai.
  ///
  /// `isOptional: true` membuat aplikasi tetap jalan dengan
  /// [defaultApiBaseUrl] ketika file hilang atau kosong, alih-alih crash.
  /// `.env` sendiri tetap harus terdaftar di `assets:` `pubspec.yaml` agar
  /// `rootBundle` bisa membacanya — lihat catatan di file itu.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env', isOptional: true);
  }
}

class ApiConfig {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? Env.defaultApiBaseUrl;

  /// Ubah path relatif hasil upload (mis. `/uploads/u/1/avatars/x.png`)
  /// jadi URL absolut memakai origin dari [baseUrl]. Backend `storage_service`
  /// memang mengembalikan path tanpa host, sedangkan `NetworkImage` di Flutter
  /// tidak mengerti path relatif. URL http(s) langsung dilewati apa adanya.
  static String resolveFileUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    final trimmed = url.trim();
    if (!trimmed.startsWith('/')) return trimmed;
    final base = Uri.tryParse(baseUrl);
    return base != null && base.host.isNotEmpty
        ? '${base.scheme}://${base.authority}$trimmed'
        : trimmed;
  }
}
