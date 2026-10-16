import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/widgets/profile_screen.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/admin/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Portofolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ProfileScreen(slug: 'admin'),
      routes: {
        '/admin': (_) => const AdminDashboard(),
      },
    );
  }
}
