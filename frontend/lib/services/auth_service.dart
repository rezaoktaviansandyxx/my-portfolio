import 'package:dio/dio.dart';
import 'package:frontend/constants/api_config.dart';
import 'package:frontend/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  final Dio _dio;

  AuthService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

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
    final res = await _dio.post(
      '/auth/login',
      data: {'username': username.trim(), 'password': password},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final token = res.data['access_token'] as String;
    _applyToken(token);
    await _persist(token);
    return token;
  }

  Future<UserModel> me() async {
    final res = await _dio.get('/auth/me');
    return UserModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    _applyToken(null);
    await _persist(null);
  }

  Dio get dio => _dio;
}
