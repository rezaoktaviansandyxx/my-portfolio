import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_service.dart';

/// Payload persis seperti yang dikirim backend untuk
/// `GET /public/u/{slug}/profile` (schema `PublicProfileResponse`).
///
/// PENTING: field `id`, `email`, `role`, `is_active`, dan `is_published`
/// TIDAK ada di sini — backend sengaja menyembunyikannya dari profil publik
/// (lihat `backend/app/schemas/auth.py` + test anti-bocor
/// `backend/tests/test_low_items.py::test_public_profile_hides_internal_fields`).
const Map<String, dynamic> kPublicProfilePayload = {
  'username': 'indraokisandy',
  'full_name': 'Indra Oki Sandy',
  'headline': 'Frontend Developer',
  'bio': null,
  'avatar_url': 'https://avatars.githubusercontent.com/u/81407568?v=4&size=64',
  'resume_url': null,
  'profile_slug': 'indra-oki-sandy',
};

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
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );

  test('getProfile membaca payload profil publik yang tanpa id/email', () async {
    // Fix target: dulu profil publik diparse dengan `UserModel.fromJson`
    // yang WAJIB punya `id` & `email`. Backend tidak mengirim keduanya,
    // jadi parse melempar TypeError -> halaman tampil "Gagal terhubung
    // ke server." padahal responsnya 200 OK.
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(200, kPublicProfilePayload);
    final service = ApiService(dio);

    final profile = await service.getProfile('indra-oki-sandy');

    expect(profile.username, 'indraokisandy');
    expect(profile.fullName, 'Indra Oki Sandy');
    expect(profile.headline, 'Frontend Developer');
    expect(profile.profileSlug, 'indra-oki-sandy');
    expect(profile.avatarUrl, contains('avatars.githubusercontent.com'));
  });

  test('getProfile tidak bocorkan field internal ke model publik', () async {
    // `id`/`email` tidak boleh ada di model profil publik: kalau ada,
    // UI bisa menampilkan email login kreator ke pengunjung.
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(200, kPublicProfilePayload);
    final service = ApiService(dio);

    final profile = await service.getProfile('indra-oki-sandy');

    expect(profile.toJson().containsKey('email'), isFalse);
    expect(profile.toJson().containsKey('id'), isFalse);
  });

  test('getProfile mengubah error parsing jadi ApiException', () async {
    // Error parsing mentah (TypeError) sebelumnya lolos dari `getProfile`
    // karena hanya `DioException` yang ditangkap -> UI tidak bisa
    // membedakan "server error" dari "respons rusak".
    //
    // `username` jadi angka: field wajib dengan tipe salah, sehingga parse
    // gagal total (bukan sekadar field opsional yang hilang).
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(200, {'username': 123});
    final service = ApiService(dio);

    await expectLater(
      service.getProfile('x'),
      throwsA(isA<ApiException>()),
    );
  });

  test('getProfile 404 tetap ApiException dengan status 404', () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter(404, {
        'detail': 'Profil tidak ditemukan',
      });
    final service = ApiService(dio);

    await expectLater(
      service.getProfile('hilang'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.isNotFound, 'isNotFound', isTrue)
            .having((e) => e.message, 'message', 'Profil tidak ditemukan'),
      ),
    );
  });
}
