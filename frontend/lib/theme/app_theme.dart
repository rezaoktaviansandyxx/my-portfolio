import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
  );
}
