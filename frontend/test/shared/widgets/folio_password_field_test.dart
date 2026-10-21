import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/folio_field.dart';

void main() {
  testWidgets('folioPasswordField menyembunyikan password secara default', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'rahasia123');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: folioPasswordField(controller, 'Password*')),
      ),
    );

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
      reason: 'password harus tersembunyi sampai tombol mata ditekan',
    );
  });

  testWidgets('tombol mata men-toggle password tanpa mengubah nilainya', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'rahasia123');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: folioPasswordField(controller, 'Password*')),
      ),
    );

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
      reason: 'password harus terlihat setelah tombol mata ditekan',
    );
    expect(controller.text, 'rahasia123');

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
      reason: 'password harus tersembunyi lagi setelah diketuk dua kali',
    );
    expect(controller.text, 'rahasia123');
  });
}
