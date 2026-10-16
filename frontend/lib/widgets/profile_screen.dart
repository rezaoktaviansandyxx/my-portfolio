import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/widgets/skills_section.dart';
import 'package:frontend/widgets/projects_section.dart';

class ProfileScreen extends ConsumerWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(slug));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyColor(Colors.grey),
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
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

extension on TextStyle {
  TextStyle copyColor(MaterialColor color) {
    return copyWith(color: color);
  }
}