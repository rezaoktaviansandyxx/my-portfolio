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
  setUpAll(() =>
      dotenv.loadFromString(envString: 'API_BASE_URL=https://api.example.com'));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('pull-to-refresh memicu provider dashboard memuat ulang data', (
    tester,
  ) async {
    var projectBuilds = 0;

    // Override provider dengan fungsi yang menghitung setiap kali dibangun.
    // Fix target: sebelum perbaikan, pull gestur TIDAK PERNAH memicu refresh
    // (RefreshIndicator mati dalam body bukan-scrollable).
    final overrides = [
      myProfileProvider.overrideWith((ref) async {
        return UserModel(id: 1, username: 'andini', email: 'a@e.com');
      }),
      myProjectsProvider.overrideWith((ref) async {
        projectBuilds++;
        return <ProjectModel>[];
      }),
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

    final buildsBefore = projectBuilds;
    expect(buildsBefore, greaterThanOrEqualTo(1));

    // RefreshIndicator kini hidup di shell (bukan dalam body non-scrollable).
    final refreshScroll = find.descendant(
      of: find.byType(RefreshIndicator),
      matching: find.byType(SingleChildScrollView),
    );
    expect(refreshScroll, findsOneWidget);

    // Resep resmi test RefreshIndicator Flutter: fling ke bawah lalu pump.
    await tester.fling(refreshScroll.first, const Offset(0, 400), 800);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(
      projectBuilds,
      greaterThan(buildsBefore),
      reason: 'pull-to-refresh wajib menyebabkan invalidate provider',
    );

    await tester.pumpAndSettle();
  });
}
