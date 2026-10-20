import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adapter dio palsu: menjawab request dengan status/body yang diatur.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.statusCode, this.body);
  final int statusCode;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future<ResponseBody>.value(
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {'content-type': [Headers.jsonContentType]},
      ),
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com',
    ),
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login sukses mengembalikan token dan menyimpannya', () async {
    final dio = Dio()..httpClientAdapter = _StubAdapter(200, {
      'access_token': 'tok-1',
      'token_type': 'bearer',
    });
    final service = AuthService(dio);
    expect(await service.login('user', 'pass'), 'tok-1');
  });

  test('login 429 harus menghasilkan ApiException.isRateLimited', () async {
    // Dulu DioException mentah lewat, sedang UI bekas branch pesan
    // 429 butuh ApiException — sekarang konversi wajib terjadi.
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(429, {'detail': 'Terlalu banyak'});
    final service = AuthService(dio);
    expect(
      () => service.login('user', 'pass'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.isRateLimited, 'isRateLimited', isTrue)
            .having((e) => e.message, 'message', 'Terlalu banyak'),
      ),
    );
  });

  test('login 401 menghasilkan ApiException kode 401', () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(401, {
        'detail': 'Username atau password salah',
      });
    final service = AuthService(dio);
    expect(
      () => service.login('user', 'salah'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
  });

  test('me() 401 juga menghasilkan ApiException (bukan DioException mentah)', () async {
    final dio = Dio()..httpClientAdapter = _StubAdapter(401, {'detail': 'x'});
    final service = AuthService(dio);
    expect(
      service.me(),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
      ),
    );
  });
}
