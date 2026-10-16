import 'package:dio/dio.dart';
import 'package:frontend/constants/api_config.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  String? _token;

  String? get token => _token;

  bool get isAuthenticated => _token != null;

  void setToken(String token) {
    _token = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _token = null;
    _dio.options.headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await _dio.post(
      '${ApiConfig.baseUrl}/auth/login',
      data: {'username': username, 'password': password},
    );
    final token = res.data['access_token'] as String;
    setToken(token);
    return res.data;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _dio.post(
      '${ApiConfig.baseUrl}/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        if (fullName != null) 'full_name': fullName,
      },
    );
  }

  Future<void> logout() async {
    // Token is cleared client-side
    clearToken();
  }
}
