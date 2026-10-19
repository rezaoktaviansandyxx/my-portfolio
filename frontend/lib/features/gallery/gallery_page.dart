import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

/// Katalog proyek publik lintas kreator: "/gallery".
class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ProjectModel> _filter(List<ProjectModel> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              (p.summary ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(galleryProjectsProvider);

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'F',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'FolioSpace',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Masuk'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: const InputDecoration(
                        hintText: 'Cari proyek atau teknologi...',
                        prefixIcon: Icon(Icons.search_rounded, size: 19),
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text('Public projects', style: AppText.title),
                    const SizedBox(height: 4),
                    Text(
                      'Karya yang sudah dipublish oleh para kreator.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 18),
                    async.when(
                      data: (all) {
                        final items = _filter(all);
                        if (items.isEmpty) {
                          return const EmptyCard(
                            title: 'Tidak ada hasil',
                            subtitle: 'Coba kata kunci lain.',
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 360,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                mainAxisExtent: 300,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) =>
                              _GalleryCard(project: items[i]),
                        );
                      },
                      loading: () => const ListSkeleton(rows: 4),
                      error: (e, _) => ErrorCard(
                        message: 'Gagal memuat galeri: $e',
                        onRetry: () => ref.invalidate(galleryProjectsProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  final ProjectModel project;

  const _GalleryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final owner = project.owner;
    final slug = owner?.profileSlug;
    return HoverScale(
      onTap: slug == null ? null : () => context.go('/u/$slug'),
      child: GlassCard(
        blur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppNetworkImage(
                url: project.coverImageUrl,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.summary ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ClipOval(
                        child: AppNetworkImage(
                          url: owner?.avatarUrl,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          owner?.fullName ?? 'Kreator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
