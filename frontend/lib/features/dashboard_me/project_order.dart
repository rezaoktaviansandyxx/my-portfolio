import 'package:frontend/core/models/project_model.dart';

/// Meratakan urutan drag-and-drop lokal dengan data terbaru dari server.
///
/// Aturan:
/// - Daftar `[previous]` kosong (seed pertama): pakai `[latest]` apa adanya.
/// - Set id sama (tambah/ubah isi, jumlah & id tetap): pakai model *terbaru*
///   supaya hasil edit tampil segar, tapi urutan custom hasil drag jaga.
/// - Id berubah (tambah/hapus item): urutan custom di-reset ke server —
///   urutan lama tidak lagi valid.
///
/// Fungsi murni (tanpa state widget) agar mudah diuji; bug lama: `_localOrder`
/// hanya di-seed ulang saat jumlah berubah, sehingga judul/isi hasil edit()
/// tidak pernah tampil sampai user menambah/menghapus proyek.
List<ProjectModel> mergeProjectOrder(
  List<ProjectModel> previous,
  List<ProjectModel> latest,
) {
  if (previous.isEmpty || latest.isEmpty) {
    return List<ProjectModel>.of(latest);
  }
  final previousIds = previous.map((p) => p.id).toSet();
  final latestIds = latest.map((p) => p.id).toSet();
  // Set id tidak identik → urutan custom tidak berlaku lagi.
  if (previousIds.length != latestIds.length ||
      !previousIds.containsAll(latestIds)) {
    return List<ProjectModel>.of(latest);
  }
  final latestById = {for (final project in latest) project.id: project};
  return [
    for (final old in previous) latestById[old.id]!,
  ];
}
