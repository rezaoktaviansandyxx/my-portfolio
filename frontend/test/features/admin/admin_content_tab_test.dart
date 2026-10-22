import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/admin/admin_dashboard_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ApiService palsu yang hanya mencatat payload `adminCreateProject`.
/// Jaringan asli tidak pernah disentuh: yang diuji payload-nya, bukan HTTP.
class _RecordingApiService extends ApiService {
  _RecordingApiService() : super(Dio());

  final List<Map<String, dynamic>> created = [];

  @override
  Future<ProjectModel> adminCreateProject(Map<String, dynamic> payload) async {
    created.add(payload);
    return ProjectModel(id: 1, title: 'Proyek Uji', slug: 'proyek-uji');
  }
}

/// Isi dialog proyek dan tekan Simpan.
Future<void> _submitProjectDialog(WidgetTester tester) async {
  await tester.tap(find.text('Tambah proyek'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextField, 'Judul*'),
    'Proyek Uji',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Slug*'),
    'proyek-uji',
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Ringkasan* (min 10 karakter)'),
    'Ringkasan proyek untuk pengujian.',
  );
  await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(
    () => dotenv.loadFromString(
      envString: 'API_BASE_URL=https://api.example.com/api/v1',
    ),
  );
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tab Skill & Pengalaman menampilkan skill dari provider', (
    tester,
  ) async {
    // Sidebar DashboardShell hanya tampil pada layout lebar; surface default
    // 800x600 menyembunyikannya di balik drawer.
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminUsersProvider.overrideWith((ref) async => <UserModel>[]),
          adminMessagesProvider.overrideWith(
            (ref) async => <Map<String, dynamic>>[],
          ),
          adminProjectsProvider.overrideWith((ref) async => <ProjectModel>[]),
          adminProjectsFilteredProvider.overrideWith(
            (ref, ownerId) async => <ProjectModel>[],
          ),
          adminSkillsProvider.overrideWith(
            (ref, ownerId) async =>
                [SkillModel(id: 1, name: 'Flutter', category: 'Frontend')],
          ),
          adminExperiencesProvider.overrideWith(
            (ref, ownerId) async => <ExperienceModel>[],
          ),
        ],
        child: const MaterialApp(home: AdminDashboard()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skill & Pengalaman').first);
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsWidgets);
  });

  testWidgets(
    'filter kreator menentukan owner_id saat admin membuat proyek',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final api = _RecordingApiService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(api),
            adminUsersProvider.overrideWith(
              (ref) async => [
                UserModel(
                  id: 7,
                  username: 'alice',
                  email: 'alice@x.com',
                  fullName: 'Alice',
                ),
              ],
            ),
            adminMessagesProvider.overrideWith(
              (ref) async => <Map<String, dynamic>>[],
            ),
            adminProjectsProvider.overrideWith((ref) async => <ProjectModel>[]),
            adminProjectsFilteredProvider.overrideWith(
              (ref, ownerId) async => <ProjectModel>[],
            ),
            adminSkillsProvider.overrideWith(
              (ref, ownerId) async => <SkillModel>[],
            ),
            adminExperiencesProvider.overrideWith(
              (ref, ownerId) async => <ExperienceModel>[],
            ),
          ],
          child: const MaterialApp(home: AdminDashboard()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Semua Proyek').first);
      await tester.pumpAndSettle();

      // Tanpa filter kreator: payload TIDAK boleh membawa owner_id, supaya
      // proyek baru tetap milik admin (perilaku lama).
      await _submitProjectDialog(tester);
      expect(api.created, hasLength(1));
      expect(api.created.single.containsKey('owner_id'), isFalse);
      expect(api.created.single['title'], 'Proyek Uji');
      expect(api.created.single['slug'], 'proyek-uji');

      // Dengan filter kreator = Alice: payload HARUS membawa owner_id,
      // kalau tidak proyek tercipta diam-diam milik admin dan tidak muncul
      // di daftar yang sedang difilter.
      await tester.tap(find.byType(DropdownButton2<int?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alice').last);
      await tester.pumpAndSettle();

      await _submitProjectDialog(tester);
      expect(api.created, hasLength(2));
      expect(api.created.last['owner_id'], 7);
      expect(api.created.last['title'], 'Proyek Uji');
      expect(api.created.last['slug'], 'proyek-uji');
    },
  );
}
