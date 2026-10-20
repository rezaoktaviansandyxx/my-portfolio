import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

void main() {
  testWidgets('shows mobile below the 900px breakpoint', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveLayout(
            mobile: Text('MOBILE'),
            desktop: Text('DESKTOP'),
          ),
        ),
      ),
    );

    expect(find.text('MOBILE'), findsOneWidget);
    expect(find.text('DESKTOP'), findsNothing);
  });

  testWidgets('shows desktop at 901px', (tester) async {
    tester.view.physicalSize = const Size(901, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveLayout(
            mobile: Text('MOBILE'),
            desktop: Text('DESKTOP'),
          ),
        ),
      ),
    );

    expect(find.text('DESKTOP'), findsOneWidget);
    expect(find.text('MOBILE'), findsNothing);
  });
}
