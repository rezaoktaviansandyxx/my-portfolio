import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/features/dashboard_me/project_order.dart';

ProjectModel _p(int id, String title) =>
    ProjectModel(id: id, title: title, slug: 'slug-$id');

void main() {
  group('mergeProjectOrder', () {
    test('seed awal (urutan kosong): pakai data server apa adanya', () {
      final latest = [_p(1, 'A'), _p(2, 'B')];
      final merged = mergeProjectOrder(const [], latest);
      expect(merged.map((p) => p.id), [1, 2]);
      expect(merged.map((p) => p.title), ['A', 'B']);
    });

    test('setelah edit (jumlah sama): judul terbaru tampil, urutan tetap', () {
      // Urutan custom hasil drag: B dulu, baru A.
      final previous = [_p(2, 'B lama'), _p(1, 'A lama')];
      // Data server terbaru: A sekarang bernama 'A baru' (hasil edit).
      final latest = [_p(1, 'A baru'), _p(2, 'B baru')];
      final merged = mergeProjectOrder(previous, latest);
      expect(merged.map((p) => p.id), [2, 1]);
      expect(merged.map((p) => p.title), ['B baru', 'A baru']);
    });

    test('tambah proyek baru: urutan di-reset ke data server', () {
      final previous = [_p(2, 'B'), _p(1, 'A')];
      final latest = [_p(3, 'C'), _p(1, 'A'), _p(2, 'B')];
      final merged = mergeProjectOrder(previous, latest);
      expect(merged.map((p) => p.id), [3, 1, 2]);
    });

    test('hapus proyek: item terhapus tidak muncul lagi', () {
      final previous = [_p(2, 'B'), _p(1, 'A')];
      final latest = [_p(1, 'A baru')];
      final merged = mergeProjectOrder(previous, latest);
      expect(merged.map((p) => p.id), [1]);
      expect(merged.single.title, 'A baru');
    });

    test('edit tanpa mengubah jumlah: konten ikut membesar segar', () {
      final previous = [_p(1, 'A lama'), _p(2, 'B lama')];
      final latest = [_p(1, 'A diperbarui'), _p(2, 'B')];
      final merged = mergeProjectOrder(previous, latest);
      expect(merged.map((p) => p.title), ['A diperbarui', 'B']);
    });

    test('data server kosong: menghasilkan daftar kosong', () {
      final previous = [_p(1, 'A')];
      expect(mergeProjectOrder(previous, const []), isEmpty);
    });
  });
}
