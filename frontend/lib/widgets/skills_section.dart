import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/app_providers.dart';

class SkillsSection extends ConsumerWidget {
  final String slug;

  const SkillsSection({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(userSkillsProvider(slug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keahlian', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        skillsAsync.when(
          data: (skills) => Wrap(
            spacing: 8,
            children: skills.map<Widget>((s) {
              return Chip(
                label: Text(s.name),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              );
            }).toList(),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
        ),
      ],
    );
  }
}