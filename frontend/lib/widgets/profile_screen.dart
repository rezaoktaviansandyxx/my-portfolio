import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:frontend/models/experience_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/contact_section.dart';
import 'package:frontend/widgets/dashboard/skeleton.dart';

/// Halaman publik:
/// "/" -> portofolio default (slug 'admin'), "/u/:slug" -> portofolio kreator.
/// Bisa dibuka tanpa login. Kalau pemilik sudah login, tombol kanan atas
/// mengarah ke dashboard masing-masing.
class ProfileScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scrollController = ScrollController();
  final _contactKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToContact() {
    final ctx = _contactKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL tidak valid')));
      return;
    }
    final ok = await launcher.launchUrl(
      uri,
      mode: launcher.LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak bisa membuka URL, disalin ke clipboard'),
        ),
      );
    }
  }

  /// Bedakan 404 (slug tidak publish/asing) vs gagal jaringan/server.
  String _profileErrorMessage(Object error) {
    if (error is ApiException) {
      if (error.isNotFound) {
        return 'Profil "${widget.slug}" tidak ditemukan atau belum dipublish.';
      }
      return 'Gagal memuat profil: ${error.message}';
    }
    return 'Gagal terhubung ke server. Periksa koneksi lalu coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    final profileAsync = ref.watch(userProfileProvider(slug));
    final auth = ref.watch(authNotifierProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? FolioDarkColors.bg : FolioColors.bg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: dark ? FolioDarkColors.primary : FolioColors.primary,
                borderRadius: BorderRadius.circular(9),
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
            const SizedBox(width: 8),
            const Text(
              'FolioSpace',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/gallery'),
            child: const Text('Galeri'),
          ),
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
                  backgroundColor: dark
                      ? FolioDarkColors.primary
                      : FolioColors.ink,
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
                label: Text(auth.isAdmin ? 'Admin' : 'Dashboard'),
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (user) {
          final name = user.fullName ?? user.username;
          final skillsAsync = ref.watch(userSkillsProvider(slug));
          final projectsAsync = ref.watch(userProjectsProvider(slug));
          final experiencesAsync = ref.watch(userExperiencesProvider(slug));
          return SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1020),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCard(
                        user: user,
                        name: name,
                        wide: wide,
                        dark: dark,
                        onContact: _scrollToContact,
                        onOpenUrl: _openUrl,
                      ),
                      const SizedBox(height: 14),
                      _section(
                        dark: dark,
                        icon: Icons.bolt_rounded,
                        title: 'Keahlian',
                        subtitle: 'Teknologi dan tools yang dikuasai',
                        child: skillsAsync.when(
                          data: (skills) {
                            if (skills.isEmpty) {
                              return const EmptyCard(
                                title: 'Belum ada skill',
                                subtitle: 'Kreator belum menambahkan keahlian.',
                              );
                            }
                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skills
                                  .map(
                                    (s) => Chip(
                                      label: Text(s.name),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                          loading: () => const ListSkeleton(rows: 2),
                          error: (e, _) => ErrorCard(
                            message: 'Gagal memuat skill: $e',
                            onRetry: () =>
                                ref.invalidate(userSkillsProvider(slug)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _section(
                        dark: dark,
                        icon: Icons.work_outline_rounded,
                        title: 'Pengalaman',
                        subtitle: 'Riwayat kerja dan organisasi',
                        child: experiencesAsync.when(
                          data: (experiences) {
                            if (experiences.isEmpty) {
                              return const EmptyCard(
                                title: 'Belum ada pengalaman',
                                subtitle:
                                    'Riwayat kerja kreator akan tampil di sini.',
                              );
                            }
                            return _ExperienceTimeline(
                              experiences: experiences.take(20).toList(),
                            );
                          },
                          loading: () => const ListSkeleton(rows: 3),
                          error: (e, _) => ErrorCard(
                            message: 'Gagal memuat pengalaman: $e',
                            onRetry: () =>
                                ref.invalidate(userExperiencesProvider(slug)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _section(
                        dark: dark,
                        icon: Icons.folder_copy_outlined,
                        title: 'Proyek pilihan',
                        subtitle: 'Karya dan riset terbaik',
                        child: projectsAsync.when(
                          data: (projects) {
                            if (projects.isEmpty) {
                              return const EmptyCard(
                                title: 'Belum ada proyek',
                                subtitle: 'Karya kreator akan tampil di sini.',
                              );
                            }
                            return _ProjectGrid(
                              projects: projects.take(10).toList(),
                              onOpenUrl: _openUrl,
                            );
                          },
                          loading: () => const ListSkeleton(rows: 3),
                          error: (e, _) => ErrorCard(
                            message: 'Gagal memuat proyek: $e',
                            onRetry: () =>
                                ref.invalidate(userProjectsProvider(slug)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ContactSection(key: _contactKey, slug: slug),
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
                message: _profileErrorMessage(error),
                onRetry: () => ref.invalidate(userProfileProvider(slug)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kartu section dengan judul + ikon di atas spinner/daftar.
  Widget _section({
    required bool dark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: dark
                        ? FolioDarkColors.primarySoft
                        : FolioColors.primarySoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: dark ? FolioDarkColors.primary : FolioColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: dark
                              ? FolioDarkColors.muted
                              : FolioColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Kartu profil paling atas: band gradasi di belakang avatar besar,
/// badge status, headline, bio, dan tombol aksi.
class _HeroCard extends StatelessWidget {
  final UserModel user;
  final String name;
  final bool wide;
  final bool dark;
  final VoidCallback onContact;
  final void Function(String) onOpenUrl;

  const _HeroCard({
    required this.user,
    required this.name,
    required this.wide,
    required this.dark,
    required this.onContact,
    required this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = dark ? FolioDarkColors.card : FolioColors.card;
    final borderColor = dark ? FolioDarkColors.border : FolioColors.border;
    final ink = dark ? FolioDarkColors.ink : FolioColors.ink;
    final muted = dark ? FolioDarkColors.muted : FolioColors.muted;
    final body = dark ? FolioDarkColors.body : FolioColors.body;

    final header = ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Container(
        height: wide ? 120 : 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? const [Color(0xFF2B2557), Color(0xFF4F46E5)]
                : const [Color(0xFF3730A3), Color(0xFF6D5BF0)],
          ),
        ),
      ),
    );

    final avatar = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: CircleAvatar(
        radius: wide ? 52 : 44,
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        backgroundColor: dark
            ? FolioDarkColors.primarySoft
            : FolioColors.primarySoft,
        child: user.avatarUrl == null
            ? Icon(
                Icons.person,
                size: wide ? 52 : 44,
                color: dark ? FolioDarkColors.primary : FolioColors.primary,
              )
            : null,
      ),
    );

    final availableBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? FolioDarkColors.greenBg : FolioColors.greenBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF0E9F6E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Tersedia untuk proyek',
            style: TextStyle(
              color: Color(0xFF0E9F6E),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

    final nameText = Text(
      name,
      style: TextStyle(
        fontSize: wide ? 30 : 24,
        fontWeight: FontWeight.w800,
        color: ink,
        height: 1.15,
      ),
    );

    final headlineText = Text(
      user.headline ?? 'Kreator Portofolio',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: dark ? FolioDarkColors.primary : FolioColors.primary,
      ),
    );

    final bioText = (user.bio ?? '').isEmpty
        ? null
        : Text(
            user.bio!,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: body, height: 1.55, fontSize: 14.5),
          );

    final resumeBtn = (user.resumeUrl != null && user.resumeUrl!.isNotEmpty)
        ? OutlinedButton.icon(
            onPressed: () => onOpenUrl(user.resumeUrl!),
            icon: const Icon(Icons.download_outlined, size: 17),
            label: const Text('Unduh Resume'),
          )
        : null;

    final contactBtn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: onContact,
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Hubungi Saya'),
          style: ElevatedButton.styleFrom(
            backgroundColor: dark
                ? FolioDarkColors.primary
                : FolioColors.primary,
            foregroundColor: dark ? const Color(0xFF16182B) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        if (resumeBtn != null) ...[const SizedBox(height: 8), resumeBtn],
      ],
    );

    final ownerLinks = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Login pemilik', style: TextStyle(fontSize: 12)),
        ),
        Text('•', style: TextStyle(color: muted, fontSize: 12)),
        TextButton(
          onPressed: () => context.go('/register'),
          child: const Text('Buat portofolio', style: TextStyle(fontSize: 12)),
        ),
      ],
    );

    if (!wide) {
      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    Align(alignment: Alignment.centerLeft, child: avatar),
                    const SizedBox(height: 12),
                    availableBadge,
                    const SizedBox(height: 10),
                    nameText,
                    const SizedBox(height: 2),
                    headlineText,
                    if (bioText != null) ...[
                      const SizedBox(height: 10),
                      bioText,
                    ],
                    const SizedBox(height: 16),
                    contactBtn,
                    const SizedBox(height: 4),
                    ownerLinks,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Transform.translate(
            offset: const Offset(0, -48),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      avatar,
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            availableBadge,
                            const SizedBox(height: 10),
                            nameText,
                            const SizedBox(height: 2),
                            headlineText,
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (bioText != null) ...[
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: bioText,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox(width: 190, child: contactBtn)],
                  ),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: ownerLinks),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Daftar pengalaman bersifat timeline: garis + titik di sisi kiri.
class _ExperienceTimeline extends StatelessWidget {
  final List<ExperienceModel> experiences;
  const _ExperienceTimeline({required this.experiences});

  String _dateRange(DateTime? start, DateTime? end, bool isCurrent) {
    String fmt(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
    final s = start != null ? fmt(start) : '?';
    final e = isCurrent ? 'Sekarang' : (end != null ? fmt(end) : '?');
    return '$s – $e';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final line = dark ? FolioDarkColors.border : FolioColors.border;
    final muted = dark ? FolioDarkColors.muted : FolioColors.muted;
    final body = dark ? FolioDarkColors.body : FolioColors.body;

    return Column(
      children: [
        for (var i = 0; i < experiences.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dark
                              ? FolioDarkColors.primary
                              : FolioColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i < experiences.length - 1)
                        Expanded(
                          child: Center(
                            child: VerticalDivider(
                              width: 2,
                              thickness: 2,
                              color: line,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${experiences[i].role} • ${experiences[i].company}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: dark ? FolioDarkColors.ink : FolioColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _dateRange(
                          experiences[i].startDate,
                          experiences[i].endDate,
                          experiences[i].isCurrent,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                      if ((experiences[i].description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          experiences[i].description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: body,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Grid kartu proyek: cover atau placeholder, judul, ringkasan, aksi link.
class _ProjectGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  final void Function(String) onOpenUrl;

  const _ProjectGrid({required this.projects, required this.onOpenUrl});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 208,
          ),
          itemCount: projects.length,
          itemBuilder: (_, i) => _ProjectCard(
            project: projects[i],
            onOpenUrl: onOpenUrl,
            dark: dark,
          ),
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final void Function(String) onOpenUrl;
  final bool dark;

  const _ProjectCard({
    required this.project,
    required this.onOpenUrl,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final ink = dark ? FolioDarkColors.ink : FolioColors.ink;
    final muted = dark ? FolioDarkColors.muted : FolioColors.muted;
    final soft = dark ? FolioDarkColors.primarySoft : FolioColors.primarySoft;
    final primary = dark ? FolioDarkColors.primary : FolioColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: dark ? FolioDarkColors.card : FolioColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? FolioDarkColors.border : FolioColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: project.coverImageUrl != null
                ? Image.network(
                    project.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _coverPlaceholder(soft, primary),
                  )
                : _coverPlaceholder(soft, primary),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (project.summary ?? '').isEmpty
                      ? 'Tanpa ringkasan.'
                      : project.summary!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: muted, height: 1.4),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (project.liveUrl != null && project.liveUrl!.isNotEmpty)
                      IconButton(
                        tooltip: 'Buka live demo',
                        icon: Icon(
                          Icons.language_outlined,
                          size: 20,
                          color: muted,
                        ),
                        onPressed: () => onOpenUrl(project.liveUrl!),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (project.githubUrl != null &&
                        project.githubUrl!.isNotEmpty)
                      IconButton(
                        tooltip: 'Buka GitHub',
                        icon: Icon(Icons.code_outlined, size: 20, color: muted),
                        onPressed: () => onOpenUrl(project.githubUrl!),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder(Color bg, Color fg) => Container(
    color: bg,
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, size: 36, color: fg),
  );
}
