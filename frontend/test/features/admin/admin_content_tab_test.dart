import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/admin/admin_dashboard_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}