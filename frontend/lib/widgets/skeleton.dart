import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:frontend/theme/app_theme.dart';

/// Semua efek shimmer berasal dari package `skeletonizer`.
/// File ini hanya berisi susunan layout (Bone) agar bentuknya
/// menyerupai tampilan akhir, tanpa animasi custom sendiri.

/// Pengganti box abu-abu: dibungkus Skeletonizer agar ber-shimmer.
/// Nama dipertahankan supaya pemakai lama tidak perlu diubah.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox(
      {super.key, this.width, required this.height, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Bone(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class StatCardsSkeleton extends StatelessWidget {
  const StatCardsSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final twoCol = c.maxWidth > 700;
      final item = Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Skeletonizer(
            enabled: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Bone.circle(size: 44),
                    const Spacer(),
                    Bone(
                      width: 24,
                      height: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Bone.text(words: 2),
                const SizedBox(height: 8),
                Bone(
                  width: double.infinity,
                  height: 26,
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
          ),
        ),
      );
      if (!twoCol) {
        return Column(
          children: List.generate(
              4,
              (i) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: 14), child: item)),
        );
      }
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.6,
        children: List.generate(4, (_) => item),
      );
    });
  }
}

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Skeletonizer(
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone(width: 200, height: 16),
              const SizedBox(height: 8),
              const Bone(width: 140, height: 12),
              const SizedBox(height: 16),
              Bone(
                width: double.infinity,
                height: 180,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TableSkeleton extends StatelessWidget {
  final int rows;
  const TableSkeleton({super.key, this.rows = 5});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Skeletonizer(
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Bone(width: 180, height: 16),
              const SizedBox(height: 6),
              const Bone(width: 240, height: 12),
              const SizedBox(height: 16),
              ...List.generate(
                rows,
                (i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Bone.circle(size: 36),
                      const SizedBox(width: 12),
                      const Expanded(child: Bone.text(words: 2)),
                      const SizedBox(width: 12),
                      Bone(
                        width: 64,
                        height: 24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCardSkeleton extends StatelessWidget {
  const ProfileCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Skeletonizer(
          enabled: true,
          child: Row(
            children: [
              Bone.circle(size: 60),
              const SizedBox(width: 14),
              const Expanded(child: Bone.text(words: 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int rows;
  const ListSkeleton({super.key, this.rows = 4});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Skeletonizer(
          enabled: true,
          child: Column(
            children: List.generate(
              rows,
              (i) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8),
                child: Bone(
                  width: double.infinity,
                  height: 56,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorCard(
      {super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: FolioColors.muted, size: 32),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyCard(
      {super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined,
                color: FolioColors.muted, size: 32),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: const TextStyle(color: FolioColors.muted),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
