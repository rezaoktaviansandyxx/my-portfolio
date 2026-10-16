import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/dashboard/skeleton.dart';

/// Halaman publik:
/// "/" -> portofolio default (slug 'admin'), "/u/:slug" -> portofolio kreator.
/// Bisa dibuka tanpa login. Kalau pemilik sudah login, tombol kanan atas
/// mengarah ke dashboard masing-masing.
class ProfileScreen extends ConsumerWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(slug));
    final auth = ref.watch(authNotifierProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: FolioColors.bg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: FolioColors.ink,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: const Text('F',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
            const Text('FolioSpace',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/register'),
            child: const Text('Buat portofolio'),
          ),
          const SizedBox(width: 4),
          if (!auth.isAuthenticated)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.lock_outline, size: 16),
                label: const Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FolioColors.ink,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.go(auth.isAdmin ? '/admin' : '/dashboard'),
                icon: const Icon(Icons.dashboard_outlined, size: 16),
                label:
                    Text(auth.isAdmin ? 'Admin' : 'Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FolioColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (user) {
          final name = user.fullName ?? user.username;
          final skillsAsync = ref.watch(userSkillsProvider(slug));
          final projectsAsync =
              ref.watch(userProjectsProvider(slug));
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 1020),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(wide ? 32 : 20),
                          child: wide
                              ? Row(
                                  children: [
                                    _avatar(user.avatarUrl, 56),
                                    const SizedBox(width: 24),
                                    Expanded(
                                        child: _heroText(
                                            context, user, name)),
                                    const SizedBox(width: 24),
                                    _heroCta(context, user),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _avatar(user.avatarUrl, 56),
                                    const SizedBox(height: 16),
                                    _heroText(
                                        context, user, name,
                                        centered: true),
                                    const SizedBox(height: 16),
                                    _heroCta(context, user),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: skillsAsync.when(
                            data: (skills) {
                              if (skills.isEmpty) {
                                return const EmptyCard(
                                  title: 'Belum ada skill',
                                  subtitle:
                                      'Kreator belum menambahkan keahlian.',
                                );
                              }
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Keahlian',
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.w800,
                                          fontSize: 16)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: skills
                                        .map((s) => Chip(
                                            label:
                                                Text(s.name)))
                                        .toList(),
                                  ),
                                ],
                              );
                            },
                            loading: () =>
                                const ListSkeleton(rows: 2),
                            error: (e, _) => ErrorCard(
                              message: 'Gagal memuat skill: $e',
                              onRetry: () => ref.invalidate(
                                  userSkillsProvider(slug)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20),
                          child: projectsAsync.when(
                            data: (projects) {
                              if (projects.isEmpty) {
                                return const EmptyCard(
                                  title: 'Belum ada proyek',
                                  subtitle:
                                      'Karya kreator akan tampil di sini.',
                                );
                              }
                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text('Proyek pilihan',
                                      style: TextStyle(
                                          fontWeight:
                                              FontWeight.w800,
                                          fontSize: 16)),
                                  const SizedBox(height: 12),
                                  ...projects.take(10).map((p) =>
                                      ListTile(
                                        contentPadding:
                                            EdgeInsets.zero,
                                        leading: p.coverImageUrl !=
                                                null
                                            ? CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(p
                                                        .coverImageUrl!))
                                            : const CircleAvatar(
                                                child: Icon(Icons
                                                    .work_outline)),
                                        title: Text(p.title,
                                            style:
                                                const TextStyle(
                                                    fontWeight:
                                                        FontWeight
                                                            .w700)),
                                        subtitle: Text(
                                            p.summary ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow
                                                .ellipsis),
                                      )),
                                ],
                              );
                            },
                            loading: () =>
                                const ListSkeleton(rows: 3),
                            error: (e, _) => ErrorCard(
                              message: 'Gagal memuat proyek: $e',
                              onRetry: () => ref.invalidate(
                                  userProjectsProvider(
                                      slug)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1020),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  children: [
                    ProfileCardSkeleton(),
                    SizedBox(height: 14),
                    ListSkeleton(rows: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorCard(
                message:
                    'Profil "$slug" tidak ditemukan.\n$error\n\nPastikan backend jalan dan user sudah publish.',
                onRetry: () =>
                    ref.invalidate(userProfileProvider(slug)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(String? url, double r) => CircleAvatar(
        radius: r,
        backgroundImage: url != null ? NetworkImage(url) : null,
        backgroundColor: FolioColors.primarySoft,
        child: url == null
            ? const Icon(Icons.person,
                size: 44, color: FolioColors.primary)
            : null,
      );

  Widget _heroText(BuildContext context, dynamic user, String name,
      {bool centered = false}) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: FolioColors.greenBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('● Tersedia untuk proyek',
              style: TextStyle(
                  color: FolioColors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ),
        const SizedBox(height: 10),
        Text(name,
            textAlign: align,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800)),
        Text(user.headline ?? 'Kreator Portofolio',
            textAlign: align,
            style:
                const TextStyle(color: FolioColors.muted)),
        const SizedBox(height: 8),
        Text(user.bio ?? '',
            textAlign: align, maxLines: 4, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _heroCta(BuildContext context, dynamic user) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FolioColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
            ),
            child: const Text('Buat portofolio seperti ini'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login pemilik'),
          ),
        ],
      );
}
