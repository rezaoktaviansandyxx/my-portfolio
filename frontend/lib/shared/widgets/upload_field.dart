import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/folio_field.dart';

/// Fungsi upload yang disuntikkan dari pemanggil, mis.
/// `ref.read(apiServiceProvider).uploadMyAvatar`.
typedef UploadFn = Future<String> Function(MultipartFile file);

/// Turunkan content-type dari ekstensi. Backend menolak apa pun di luar
/// allowlist (`backend/app/services/storage.py:8-13`), dan Dio default ke
/// `application/octet-stream` yang PASTI ditolak — jadi wajib eksplisit.
const _mimeByExt = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
  'pdf': 'application/pdf',
};

String? mimeForExtension(String? ext) =>
    ext == null ? null : _mimeByExt[ext.toLowerCase()];

/// Bangun [MultipartFile] dengan contentType eksplisit.
MultipartFile multipartFromBytes(
  Uint8List bytes,
  String filename,
  String mime,
) => MultipartFile.fromBytes(
  bytes,
  filename: filename,
  contentType: DioMediaType.parse(mime),
);

/// Picker nyata. Dipisah agar widget bisa diuji tanpa plugin platform.
Future<({Uint8List bytes, String name})?> _pickDefault({
  required bool document,
}) async {
  final res = await FilePicker.platform.pickFiles(
    withData: true, // wajib di web: path tidak tersedia
    type: FileType.custom,
    allowedExtensions: document
        ? const ['pdf']
        : const ['jpg', 'jpeg', 'png', 'webp'],
  );
  final files = res?.files ?? const <PlatformFile>[];
  if (files.isEmpty) return null;
  final f = files.first;
  final bytes = f.bytes;
  if (bytes == null) return null;
  return (bytes: bytes, name: f.name);
}

/// Field URL dengan tombol upload di sisi kanan.
///
/// Nilai yang dihasilkan backend (`/static/uploads/...`) ditulis apa adanya ke
/// controller, karena `POST /*/media` dan `PUT /me/profile` hanya menerima
/// `^(https?://|/static/)`. Resolve ke URL absolut dilakukan saat render
/// (`AppNetworkImage`) atau saat membuka link (`ApiConfig.resolveFileUrl`).
class UploadField extends StatefulWidget {
  final TextEditingController controller;
  final UploadFn upload;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool document;

  /// Override untuk test; produksi memakai `FilePicker.platform`.
  final Future<Uint8List?> Function()? picker;
  final Future<String> Function()? fileName;

  const UploadField({
    super.key,
    required this.controller,
    required this.upload,
    required this.label,
    this.hint,
    this.icon,
    this.document = false,
    this.picker,
    this.fileName,
  });

  @override
  State<UploadField> createState() => _UploadFieldState();
}

class _UploadFieldState extends State<UploadField> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final Uint8List? bytes;
      final String name;
      if (widget.picker != null) {
        bytes = await widget.picker!();
        name = (await widget.fileName?.call()) ?? 'upload';
      } else {
        final picked = await _pickDefault(document: widget.document);
        bytes = picked?.bytes;
        name = picked?.name ?? '';
      }
      if (bytes == null) return;

      final ext = name.contains('.') ? name.split('.').last : null;
      final mime = mimeForExtension(
        ext,
      ) ?? (widget.document ? 'application/pdf' : 'image/jpeg');
      final url = await widget.upload(
        multipartFromBytes(bytes, name, mime),
      );
      if (!mounted) return;
      setState(() => widget.controller.text = url);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal upload file')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: folioField(
            widget.controller,
            widget.label,
            hint: widget.hint,
            keyboard: TextInputType.url,
            icon: widget.icon,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: IconButton(
            tooltip: widget.document ? 'Upload dokumen' : 'Upload gambar',
            onPressed: _busy ? null : _run,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file_outlined),
          ),
        ),
      ],
    );
  }
}
