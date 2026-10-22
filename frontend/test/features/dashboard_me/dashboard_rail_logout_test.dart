import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/dashboard_me/user_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com',
    ),
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Rail desktop (bukan drawer mobile) sebelumnya hanya ikon logout tanpa
  // teks. Aksi destruktif harus selalu terbaca, jadi teks "Logout" wajib ada
  // baik saat rail full maupun saat dicabut.
  testWidgets('tombol logout di rail desktop selalu membawa teks Logout', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);

    final overrides = [
      myProfileProvider.overrideWith(
        (ref) async => UserModel(
          id: 1,
          username: 'andini',
          email: 'a@e.com',
          fullName: 'Indra Oki Sandy',
        ),
      ),
      myProjectsProvider.overrideWith((ref) async => <ProjectModel>[]),
      mySkillsProvider.overrideWith((ref) async => <SkillModel>[]),
      myExperiencesProvider.overrideWith((ref) async => <ExperienceModel>[]),
      myMessagesProvider.overrideWith((ref) async => <Map<String, dynamic>>[]),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(home: UserDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // Ciutkan rail: label kecil di bawah ikon tetap ada.
    await tester.tap(find.byTooltip('Ciutkan'));
    await tester.pumpAndSettle();

    expect(find.text('Logout'), findsOneWidget);

    // Teksnya benar-benar memanggil dialog konfirmasi yang sama.
    await tester.tap(find.byTooltip('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari akun?'), findsOneWidget);
  });
}
