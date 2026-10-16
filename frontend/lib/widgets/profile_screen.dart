import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/widgets/skills_section.dart';
import 'package:frontend/widgets/projects_section.dart';

class ProfileScreen extends ConsumerWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(slug));
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!auth.isAuthenticated)
            IconButton(
              tooltip: 'Login pemilik',
              icon: const Icon(Icons.lock_outline, size: 18),
              onPressed: () => context.go('/login'),
            )
          else
            IconButton(
              tooltip: auth.isAdmin ? 'Admin' : 'Dashboard',
              icon: const Icon(Icons.dashboard_outlined, size: 18),
              onPressed: () => context.go(auth.isAdmin ? '/admin' : '/dashboard'),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (user) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.fullName ?? user.username,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  user.headline ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text('Bio', style: Theme.of(context).textTheme.titleLarge),
                Text(user.bio ?? ''),
                const SizedBox(height: 24),
                SkillsSection(slug: slug),
                const SizedBox(height: 24),
                ProjectsSection(slug: slug),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text(
                'Pastikan backend jalan di :8000 dan user punya profile_slug + is_published=true.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(userProfileProvider(slug)),
                child: const Text('Coba lagi'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
