import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/app_providers.dart';

class ProjectsSection extends ConsumerWidget {
  final String slug;

  const ProjectsSection({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider(slug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Proyek', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        projectsAsync.when(
          data: (projects) => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const Divider(height: 24),
            itemBuilder: (_, i) {
              final p = projects[i];
              return ListTile(
                leading: p.coverImageUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(p.coverImageUrl!))
                    : const Icon(Icons.folder, size: 40),
                title: Text(p.title),
                subtitle: Text(p.summary ?? ''),
                trailing: p.liveUrl != null
                    ? IconButton(
                        icon: const Icon(Icons.link),
                        onPressed: () => launchUrl(p.liveUrl!),
                      )
                    : null,
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
        ),
      ],
    );
  }
}

void launchUrl(String url) {
  // Simple placeholder — integrate url_launcher in real app
  log('Launch URL: $url');
}
