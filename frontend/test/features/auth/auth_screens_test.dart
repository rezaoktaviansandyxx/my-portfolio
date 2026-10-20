import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:frontend/features/auth/register_screen.dart';

Widget _wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

void main() {
  testWidgets('LoginScreen menyajikan form login tanpa kartu register', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Register'), findsNothing);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    // Tautan silang ke register dan pintu keluar ke galeri.
    expect(find.text('Belum punya akun? Register'), findsOneWidget);
    expect(find.text('Jelajahi galeri tanpa akun'), findsOneWidget);
  });

  testWidgets('LoginScreen memvalidasi isian kosong', (tester) async {
    await tester.pumpWidget(_wrap(const LoginScreen()));
    // "Login" muncul dua kali: judul kartu dan tombol CTA. Tap yang terakhir.
    await tester.tap(find.text('Login').last);
    await tester.pump();

    expect(find.text('Username wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('RegisterScreen menyajikan form register tanpa kartu login', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const RegisterScreen()));

    expect(find.text('Register'), findsWidgets);
    expect(find.text('Login'), findsNothing);
    expect(find.text('Nama lengkap'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    // Tautan silang ke login dan pintu keluar ke galeri.
    expect(find.text('Sudah punya akun? Login'), findsOneWidget);
    expect(find.text('Jelajahi galeri tanpa akun'), findsOneWidget);
  });

  testWidgets('RegisterScreen menolak password pendek', (tester) async {
    await tester.pumpWidget(_wrap(const RegisterScreen()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nama lengkap'),
      'Budi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'budi',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'budi@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'pendek',
    );
    await tester.tap(find.text('Register').last);
    await tester.pump();

    expect(find.text('Minimal 8 karakter'), findsOneWidget);
  });
}
