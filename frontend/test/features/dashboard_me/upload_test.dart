import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

void main() {
  test('contentType diturunkan dari ekstensi (bukan octet-stream)', () {
    expect(mimeForExtension('png'), 'image/png');
    expect(mimeForExtension('webp'), 'image/webp');
    expect(mimeForExtension('jpg'), 'image/jpeg');
    expect(mimeForExtension('JPG'), 'image/jpeg');
    expect(mimeForExtension('pdf'), 'application/pdf');
    expect(mimeForExtension('exe'), isNull);
  });

  test('multipart dibangun dengan nama file & contentType benar', () {
    final f = multipartFromBytes(
      Uint8List.fromList([1, 2, 3]),
      'cv.pdf',
      'application/pdf',
    );
    expect(f.filename, 'cv.pdf');
    expect(f.contentType.toString(), 'application/pdf');
  });

  testWidgets('tombol upload memanggil UploadFn dan mengisi controller', (
    tester,
  ) async {
    final controller = TextEditingController();
    MultipartFile? received;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadField(
            controller: controller,
            label: 'Avatar URL',
            hint: 'https://...',
            upload: (file) async {
              received = file;
              return '/static/uploads/u/1/avatars/a.png';
            },
            picker: () async => Uint8List.fromList([1, 2, 3]),
            fileName: () async => 'a.png',
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(received?.filename, 'a.png');
    expect(received!.contentType.toString(), 'image/png');
    expect(controller.text, '/static/uploads/u/1/avatars/a.png');
  });

  testWidgets('upload gagal menampilkan pesan, controller tidak berubah', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'https://lama/x.png');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadField(
            controller: controller,
            label: 'Avatar URL',
            upload: (file) async => throw Exception('gagal'),
            picker: () async => Uint8List.fromList([1]),
            fileName: () async => 'x.png',
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Gagal upload file'), findsOneWidget);
    expect(controller.text, 'https://lama/x.png');
  });
}
