import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/widgets/skill_gradient.dart';

void main() {
  test('same name always yields the same gradient', () {
    final a = skillGradient('Flutter');
    final b = skillGradient('Flutter');
    expect(a.colors, b.colors);
  });

  test('is case and whitespace insensitive', () {
    final a = skillGradient('Flutter');
    final b = skillGradient('  flutter ');
    expect(a.colors, b.colors);
  });

  test('different names usually differ', () {
    final names = ['Dart', 'Flutter', 'Node.js', 'API', 'Postgres', 'Redis'];
    final keys = names
        .map((n) => skillGradient(n).colors.first.toARGB32())
        .toSet();
    expect(keys.length, greaterThan(3));
  });
}
