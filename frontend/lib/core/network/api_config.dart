import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

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
