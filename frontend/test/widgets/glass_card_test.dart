import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/glass_card.dart';

void main() {
  testWidgets('renders its child and a clipped backdrop', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: GlassCard(child: Text('ISI')))),
    );

    expect(find.text('ISI'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(ClipRRect), findsWidgets);
  });

  testWidgets('skips the backdrop when blur is disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GlassCard(blur: false, child: Text('ISI'))),
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
  });
}
