import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/auth_service.dart';
import 'package:frontend/features/auth/auth_providers.dart';

/// Fake service: menyimulasi /me gagal dengan beragam kondisi jaringan,
/// memverifikasi sesi TIDAK dihapus kecuali benar-benar tidak valid (401/403).
class _RecordingAuthService extends AuthService {
  _RecordingAuthService() : super(Dio());

  String? storedToken = 'tok-abc';
  Object? meError;
  int logoutCalls = 0;

  @override
  Future<String?> loadStoredToken() async => storedToken;

  @override
  Future<UserModel> me() async {
    final error = meError;
    if (error != null) throw error;
    return UserModel(id: 1, username: 'andini', email: 'a@e.com');
  }

  @override
  Future<void> logout() async => logoutCalls++;
}

Future<AuthState> _restoreWith(AuthService service) async {
  final container = ProviderContainer(
    overrides: [authServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  container.listen(authNotifierProvider, (_, __) {});
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return container.read(authNotifierProvider);
}

void main() {
  setUpAll(() =>
      dotenv.loadFromString(envString: 'API_BASE_URL=https://api.example.com'));

  test('tanpa token tersimpan: tidak dianggap login', () async {
    final service = _RecordingAuthService()..storedToken = null;
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isFalse);
    expect(state.token, isNull);
  });

  test('/me sukses: sesi terisi token + user', () async {
    final service = _RecordingAuthService()..meError = null;
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isTrue);
    expect(state.user?.username, 'andini');
    expect(service.logoutCalls, 0);
  });

  test('server 500 (bukan token invalid): sesi TIDAK dibersihkan', () async {
    final service = _RecordingAuthService()
      ..meError = ApiException('Kesalahan server', statusCode: 500);
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isTrue, reason: 'error transient jangan logout');
    expect(state.isLoading, isFalse);
    expect(state.user, isNull, reason: 'profil gagal dimuat, user tetap null');
    expect(service.logoutCalls, 0);
  });

  test('/connection timeout: sesi TIDAK dibersihkan', () async {
    final service = _RecordingAuthService()..meError = TimeoutException('x');
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isTrue);
    expect(service.logoutCalls, 0);
  });

  test('token kedaluwarsa (401): sesi dibersihkan via logout', () async {
    final service = _RecordingAuthService()
      ..meError = ApiException('Unauthorized', statusCode: 401);
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isFalse);
    expect(service.logoutCalls, 1);
  });

  test('akses diblokir (403): sesi dibersihkan via logout', () async {
    final service = _RecordingAuthService()
      ..meError = ApiException('Forbidden', statusCode: 403);
    final state = await _restoreWith(service);
    expect(state.isAuthenticated, isFalse);
    expect(service.logoutCalls, 1);
  });
}
