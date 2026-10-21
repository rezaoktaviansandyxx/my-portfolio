import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/public_profile_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/public_portfolio/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Payload profil publik persis seperti backend kirim (tanpa id/email).
const Map<String, dynamic> kPublicProfilePayload = {
  'username': 'indraokisandy',
  'full_name': 'Indra Oki Sandy',
  'headline': 'Frontend Developer',
  'bio': 'Bio singkat kreator.',
  'avatar_url': 'https://avatars.githubusercontent.com/u/81407568?v=4&size=64',
  'resume_url': null,
  'profile_slug': 'indra-oki-sandy',
};

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('halaman profil merender data dari respons profil publik', (
    tester,
  ) async {
    // Fix target: profil publik backend tidak mengirim `id`/`email`.
    // Sebelumnya halaman ini parse dengan UserModel (wajib punya keduanya)
    // -> TypeError -> tampil "Gagal terhubung ke server." walau API 200 OK.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref, slug) async =>
                PublicProfileModel.fromJson(kPublicProfilePayload),
          ),
          userProjectsProvider.overrideWith(
            (ref, slug) async => <ProjectModel>[],
          ),
          userSkillsProvider.overrideWith((ref, slug) async => <SkillModel>[]),
          userExperiencesProvider.overrideWith(
            (ref, slug) async => <ExperienceModel>[],
          ),
        ],
        child: const MaterialApp(home: ProfileScreen(slug: 'indra-oki-sandy')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Indra Oki Sandy'), findsWidgets);
    expect(find.text('Frontend Developer'), findsWidgets);
    expect(find.text('Gagal terhubung ke server.'), findsNothing);
    expect(find.textContaining('tidak ditemukan'), findsNothing);
  });

  testWidgets('profil publik tidak menampilkan tombol Email (mailto)', (
    tester,
  ) async {
    // Backend sengaja tidak mengirim `email` ke profil publik (test anti-bocor
    // di backend/tests/test_low_items.py). Jadi tombol Email tidak boleh
    // lagi ada di hero — kanal kontak resmi lewat form "Hire Me".
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref, slug) async =>
                PublicProfileModel.fromJson(kPublicProfilePayload),
          ),
          userProjectsProvider.overrideWith(
            (ref, slug) async => <ProjectModel>[],
          ),
          userSkillsProvider.overrideWith((ref, slug) async => <SkillModel>[]),
          userExperiencesProvider.overrideWith(
            (ref, slug) async => <ExperienceModel>[],
          ),
        ],
        child: const MaterialApp(home: ProfileScreen(slug: 'indra-oki-sandy')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsNothing);
    expect(find.text('Hire Me'), findsWidgets);
  });

  testWidgets('profil tidak dipublish menampilkan pesan 404 yang jelas', (
    tester,
  ) async {
    // Error 404 harus menampilkan pesan spesifik ("tidak ditemukan"),
    // BUKAN "Gagal terhubung ke server." yang menyesatkan — pesan generik
    // itu sempat dipakai untuk semua error, termasuk profil yang memang
    // tidak ada.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref, slug) async => throw ApiException(
              'Profil tidak ditemukan',
              statusCode: 404,
            ),
          ),
          userProjectsProvider.overrideWith(
            (ref, slug) async => <ProjectModel>[],
          ),
          userSkillsProvider.overrideWith((ref, slug) async => <SkillModel>[]),
          userExperiencesProvider.overrideWith(
            (ref, slug) async => <ExperienceModel>[],
          ),
        ],
        child: const MaterialApp(home: ProfileScreen(slug: 'tidak-ada')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('tidak ditemukan'), findsWidgets);
    expect(find.text('Gagal terhubung ke server.'), findsNothing);
  });
}
