import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';

/// Kartu proyek pada grid drag-reorder (tab Proyek dashboard).
///
/// CATATAN TATA LETAK: kartu dipasang sebagai anak langsung dari [Wrap]
/// (lihat `_reorderGrid`), dan [Wrap] memberi anaknya tinggi tak terbatas.
/// Tinggi kartu karenanya HARUS dibatasi — tanpa batasan, [Spacer] di dalam
/// [Column] meledak dengan "RenderFlex children have non-zero flex but
/// incoming height constraints are unbounded". Tinggi 132 dipilih agar pas
/// dengan `_dropzone` yang berdampingan di grid.
class ProjectReorderCard extends StatelessWidget {
  final ProjectModel project;
  final int index;
  final bool highlighted;

  /// Aksi menu ⋮ milik pemanggil (state dashboard) agar dialog & providers
  /// tetap dipicu dari tempat yang sama seperti sebelum ekstraksi.
  final VoidCallback? onEdit;
  final VoidCallback? onMedia;
  final VoidCallback? onDelete;

  const ProjectReorderCard({
    super.key,
    required this.project,
    required this.index,
    this.highlighted = false,
    this.onEdit,
    this.onMedia,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final p = project;
    return Container(
      width: 300,
      height: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.cyan.withValues(alpha: 0.10)
            : AppColors.glassFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.cyan : AppColors.glassBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNetworkImage(
                url: p.coverImageUrl,
                width: 40,
                height: 40,
                radius: 10,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      '${p.status ?? '-'} • ${(p.media ?? []).length} media',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18),
                color: const Color(0xFF171C28),
                onSelected: (v) {
                  if (v == 'edit') {
                    onEdit?.call();
                  } else if (v == 'media') {
                    onMedia?.call();
                  } else if (v == 'delete') {
                    onDelete?.call();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'media', child: Text('Tambah media')),
                  PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.drag_indicator_rounded,
                size: 15,
                color: AppColors.muted,
              ),
              const SizedBox(width: 4),
              Text('Urutan ${index + 1}', style: AppText.caption),
            ],
          ),
        ],
      ),
    );
  }
}
