import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/routers/app_router.dart';

void main() {
  runApp(const ProviderScope(child: AppRouter()));
}
