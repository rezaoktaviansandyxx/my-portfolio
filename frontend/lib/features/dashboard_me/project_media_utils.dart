import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';
import 'package:frontend/shared/widgets/errors.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

/// Alur "tambah media proyek" yang dipakai dashboard user maupun admin.
/// Mengembalikan true bila media berhasil ditambahkan.
///
/// Efek samping diserahkan ke pemanggil lewat [onChanged] (invalidate
/// provider) dan [notify] (snackbar), sehingga helper ini tidak perlu
/// memegang `WidgetRef`.
Future<bool> addProjectMediaFlow({
  required BuildContext context,
  required ProjectModel project,
  required Future<ProjectMediaModel> Function(
    String mediaUrl,
    String mediaType,
    String? caption,
  )
  add,
  required void Function() onChanged,
  required void Function(String msg, {bool error}) notify,
  UploadFn? uploadMedia,
  String? successMessage,
}) async {
  final data = await showProjectMediaDialog(
    context,
    uploadMedia: uploadMedia,
  );
  if (data == null) return false;
  final caption = (data['caption'] ?? '').trim();
  try {
    await add(data['media_url']!, data['media_type'] ?? 'image',
        caption.isEmpty ? null : caption);
    onChanged();
    notify(successMessage ?? 'Media ditambahkan ke "${project.title}"');
    return true;
  } catch (e) {
    notify(friendlyError(e, 'Gagal tambah media'), error: true);
    return false;
  }
}
