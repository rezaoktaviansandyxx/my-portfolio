import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/widgets/login_screen.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).state = authState.logout();
            },
            tooltip: 'Logout',
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 60),
            SizedBox(height: 16),
            Text('Admin Dashboard'),
            SizedBox(height: 8),
            Text('Fitur manajemen akan ditambahkan di sini'),
          ],
        ),
      ),
    );
  }
}
