import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';

void main() {
  test('dark theme is dark and uses the neon background', () {
    final t = AppTheme.dark;
    expect(t.brightness, Brightness.dark);
    expect(t.scaffoldBackgroundColor, AppColors.bg);
    expect(t.colorScheme.primary, AppColors.indigo);
  });

  test('glass tokens are translucent white', () {
    expect(AppColors.glassFill.a, lessThan(0.2));
    expect(AppColors.glassBorder.a, lessThan(0.3));
    expect(AppColors.glassFill.r, 1.0);
  });

  test('brand gradient runs violet to blue', () {
    expect(AppColors.brandGradient.colors.first, AppColors.violet);
    expect(AppColors.brandGradient.colors.last, AppColors.blue);
  });
}
