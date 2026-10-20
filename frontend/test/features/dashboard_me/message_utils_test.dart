import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/dashboard_me/message_utils.dart';

void main() {
  group('messageInitial', () {
    test('huruf pertama dinormalisasi kapital', () {
      expect(messageInitial('budi santoso'), 'B');
    });

    test('spasi depan di-trim', () {
      expect(messageInitial('  Andi'), 'A');
    });

    test('kosong/null → placeholder ? (tidak melempar RangeError)', () {
      expect(messageInitial(null), '?');
      expect(messageInitial(''), '?');
      expect(messageInitial('   '), '?');
    });
  });

  group('parseMessageId', () {
    test('num → int', () {
      expect(parseMessageId(5), 5);
      expect(parseMessageId(5.0), 5);
    });

    test('string digit → int', () {
      expect(parseMessageId('12'), 12);
    });

    test('null/tidak dikenal → null', () {
      expect(parseMessageId(null), isNull);
      expect(parseMessageId('X'), isNull);
      expect(parseMessageId({}), isNull);
    });
  });
}
