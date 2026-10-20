import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  final Dio _dio;

  AuthService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  String? _token;

  void _applyToken(String? token) {
    _token = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// Muat token tersimpan (web -> localStorage). Panggil saat startup.
  Future<String?> loadStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString(_tokenKey);
    if (t != null && t.isNotEmpty) _applyToken(t);
    return _token;
  }

  Future<void> _persist(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  /// Backend memakai OAuth2PasswordRequestForm -> harus form-urlencoded, bukan JSON.
  Future<String> login(String username, String password) async {
    final Response res;
    try {
      res = await _dio.post(
        '/auth/login',
        data: {'username': username.trim(), 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      // Konversi wajib: UI membaca ApiException (mis. isRateLimited) untuk
      // memilih pesan; DioException mentah membuat branch 429 tak tercapai.
      _throwApiError(e, 'Gagal masuk. Periksa koneksi lalu coba lagi');
    }
    final token = res.data['access_token'] as String;
    _applyToken(token);
    await _persist(token);
    return token;
  }

  Future<UserModel> me() async {
    final Response res;
    try {
      res = await _dio.get('/auth/me');
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal memuat profil');
    }
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      await _dio.post(
        '/auth/register',
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          if (fullName != null && fullName.trim().isNotEmpty)
            'full_name': fullName.trim(),
        },
      );
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal registrasi');
    }
  }

  Never _throwApiError(DioException e, String fallback) {
    final data = e.response?.data;
    String msg = fallback;
    if (data is Map && data['detail'] != null) {
      final d = data['detail'];
      msg = d is String ? d : d.toString();
    } else if (e.message != null && e.message!.isNotEmpty) {
      msg = e.message!;
    }
    throw ApiException(msg, statusCode: e.response?.statusCode);
  }

  /// PATCH /auth/change-password (body: current_password, new_password).
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.patch(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      _throwApiError(e, 'Gagal ganti password');
    }
  }

  Future<void> logout() async {
    // Panggil API resmi agar server bisa mencatat/audit logout.
    // JWT stateless: kalaupun gagal/offline, token lokal tetap dihapus.
    try {
      await _dio.post('/auth/logout');
    } catch (_) {
      // best-effort, abaikan agar logout lokal selalu berhasil
    }
    _applyToken(null);
    await _persist(null);
  }
}
