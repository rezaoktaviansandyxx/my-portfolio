import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_service.dart';

void main() {
  // Constructor ApiService membaca ApiConfig.baseUrl via dotenv; sinkronkan
  // dengan .env.example (API_BASE_URL) agar tidak butuh file .env asli.
  setUpAll(() =>
      dotenv.loadFromString(envString: 'API_BASE_URL=https://api.example.com'));

  test('saat release, logger console mati — token & password tidak tumpah', () {
    final api = ApiService(Dio(), debugLogging: false);
    expect(api.logsTraffic, isFalse);
  });

  test('logger boleh dinyalakan eksplisit saat debugging', () {
    final api = ApiService(Dio(), debugLogging: true);
    expect(api.logsTraffic, isTrue);
  });

  test('tanpa parameter, logger mengikuti kemampuan debug', () {
    // Di lingkungan `flutter test`aktif, jadi default tetap menyalakan logger.
    final api = ApiService(Dio());
    expect(api.logsTraffic, kDebugMode);
  });
}
