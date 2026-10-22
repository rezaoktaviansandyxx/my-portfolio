import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';

void main() {
  testWidgets('dialog pengalaman memakai date picker untuk tanggal', (
    tester,
  ) async {
    Map<String, dynamic>? payload;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  payload = await showExperienceDialog(context);
                },
                child: const Text('Buka'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Role*'),
      'Frontend Engineer',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Perusahaan*'),
      'FolioSpace',
    );

    // Tidak ada field teks tanggal: tanggal hanya bisa dipilih lewat picker.
    expect(find.widgetWithText(TextField, 'Mulai* (YYYY-MM-DD)'), findsNothing);

    // Tanggal wajib dipilih sebelum menyimpan.
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Tanggal mulai wajib dipilih'), findsOneWidget);
    expect(payload, isNull);

    // Ketuk ikon kalender -> date picker Syncfusion terbuka.
    await tester.tap(find.byIcon(Icons.event_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('Pilih'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog).last,
        matching: find.text('Batal'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('dialog pengalaman menampilkan tanggal lama dari data server', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showExperienceDialog(
                  context,
                  experience: ExperienceModel(
                    id: 1,
                    role: 'Frontend Engineer',
                    company: 'FolioSpace',
                    startDate: DateTime(2023, 1, 15),
                  ),
                ),
                child: const Text('Buka'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();

    expect(find.text('15 Jan 2023'), findsOneWidget);
  });
}
