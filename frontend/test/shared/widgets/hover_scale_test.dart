import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

void main() {
  testWidgets('HoverScale fokus dengan Tab dan Enter memicu aksi', (tester) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoverScale(onTap: () => presses++, child: const Text('KLIK')),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(presses, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(presses, 2);
  });

  testWidgets('HoverScale mendeklarasikan diri sebagai tombol untuk a11y', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoverScale(onTap: () {}, child: const Text('KLIK')),
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.text('KLIK'));
    expect(semantics.flagsCollection.isButton, isTrue);
  });

  testWidgets('HoverScale tanpa onTap tidak menyetel role tombol', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: HoverScale(child: Text('NON')))),
      ),
    );

    final semantics = tester.getSemantics(find.text('NON'));
    expect(semantics.flagsCollection.isButton, isFalse);
  });

  testWidgets('GlowButton: Tab + Enter menekan, disabled mematikan fokus', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlowButton(label: 'MASUK', onPressed: () => presses++),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(presses, 1);

    final semantics = tester.getSemantics(find.text('MASUK'));
    expect(semantics.flagsCollection.isButton, isTrue);
  });
}








