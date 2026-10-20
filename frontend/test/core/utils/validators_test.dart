import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/validators.dart';

void main() {
  group('kUsernamePattern', () {
    test('menerima username lowercase/underscore 3-30', () {
      expect(kUsernamePattern.hasMatch('budi_99'), isTrue);
      expect(kUsernamePattern.hasMatch('abc'), isTrue);
    });

    test('menolak huruf besar, spasi, terlalu pendek/panjang', () {
      expect(kUsernamePattern.hasMatch('Budi'), isFalse);
      expect(kUsernamePattern.hasMatch('ab'), isFalse);
      expect(kUsernamePattern.hasMatch('a' * 31), isFalse);
      expect(kUsernamePattern.hasMatch('budi santoso'), isFalse);
    });
  });

  group('kEmailPattern', () {
    test('menerima email umum, menolak tanpa @ / tld', () {
      expect(kEmailPattern.hasMatch('a@b.co'), isTrue);
      expect(kEmailPattern.hasMatch('bukan-email'), isFalse);
      expect(kEmailPattern.hasMatch('a@b'), isFalse);
    });
  });

  group('firstWordOf', () {
    test('kata pertama nama, whitespace ekstra dilucuti (satu sumber)', () {
      expect(firstWordOf('  Budi  Santoso '), 'Budi');
      expect(firstWordOf('charlie'), 'charlie');
      expect(firstWordOf('   '), '');
    });
  });

  group('initialsOf', () {
    test('inisial dari dua kata pertama, dikapitalisasi', () {
      expect(initialsOf('budi santoso'), 'BS');
      expect(initialsOf('  Dewi  Lestari '), 'DL');
      expect(initialsOf('solo'), 'S');
    });

    test('fallback dipakai saat nama kosong', () {
      expect(initialsOf('   ', fallback: 'U'), 'U');
      expect(initialsOf('   '), '?');
    });
  });

  group('kSlugPattern', () {
    test('slug lowercase dengan tanda hubung, bukan di tepi', () {
      expect(kSlugPattern.hasMatch('proyek-keren-1'), isTrue);
      expect(kSlugPattern.hasMatch('Proyek'), isFalse);
      expect(kSlugPattern.hasMatch('-proyek'), isFalse);
      expect(kSlugPattern.hasMatch('proyek--x'), isFalse);
    });
  });
}
