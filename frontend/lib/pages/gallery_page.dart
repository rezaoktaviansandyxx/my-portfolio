import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/constants/api_config.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/errors.dart';
import 'package:frontend/widgets/skeleton.dart';

/// Halaman publik: galeri proyek published dari seluruh kreator
/// (`GET /public/gallery/projects`).
class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(galleryProjectsProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: FolioColors.bg,
      appBar: AppBar(
        title: const Text('Galeri Proyek'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(galleryProjectsProvider),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: gallery.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return const EmptyCard(
                      title: 'Belum ada proyek',
                      subtitle:
                          'Proyek yang dipublikasikan kreator akan tampil di sini.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Karya terbaru dari kreator',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Proyek published dari seluruh portofolio publik.',
                        style: TextStyle(color: FolioColors.muted),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: projects.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: wide ? 3 : 1,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: wide ? 1.3 : 2.4,
                        ),
                        itemBuilder: (_, i) {
                          final p = projects[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: p.coverImageUrl != null
                                      ? Image.network(
                                          ApiConfig.resolveFileUrl(
                                              p.coverImageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.summary ?? 'Tanpa ringkasan',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: FolioColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                loading: () => const ListSkeleton(rows: 4),
                error: (e, _) => ErrorCard(
                  message: friendlyError(e, 'Gagal memuat galeri'),
                  onRetry: () => ref.invalidate(galleryProjectsProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFEEF0F6),
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, size: 40, color: FolioColors.muted),
  );
}
