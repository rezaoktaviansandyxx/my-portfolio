import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/experience_model.dart';
import 'package:frontend/models/project_model.dart';
import 'package:frontend/models/skill_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/dashboard/dashboard_shell.dart';
import 'package:frontend/widgets/dashboard/folio_widgets.dart';
import 'package:frontend/widgets/dashboard/skeleton.dart';
import 'package:frontend/widgets/user/dialogs.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  int tab = 0;

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  /// Pesan error ramah berbasis [ApiException.statusCode] (404/429),
  /// tanpa dump `$e` mentah ke pengguna.
  String _friendly(Object e, String fallback) {
    if (e is ApiException) {
      if (e.isNotFound) {
        return 'Data tidak ditemukan. Muat ulang lalu coba lagi.';
      }
      if (e.isRateLimited) {
        return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
      }
      return e.message;
    }
    return fallback;
  }

  void _refreshAll() {
    ref.invalidate(myProfileProvider);
    ref.invalidate(myProjectsProvider);
    ref.invalidate(mySkillsProvider);
    ref.invalidate(myExperiencesProvider);
    ref.invalidate(myMessagesProvider);
  }

  int _unreadCount(List<Map<String, dynamic>> list) =>
      list.where((m) => m['is_read'] != true).length;

  /// Format `created_at` ISO backend -> `dd/mm/yyyy`. Fallback 10 char.
  String _fmtDate(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '-';
    final d = DateTime.tryParse(s);
    if (d == null) return s.length > 10 ? s.substring(0, 10) : s;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final profile = ref.watch(myProfileProvider);
    final projects = ref.watch(myProjectsProvider);
    final messages = ref.watch(myMessagesProvider);

    final name =
        profile.asData?.value.fullName ?? auth.user?.username ?? 'Kreator';
    final first = name.trim().split(RegExp(r'\s+')).first;
    final msgList = messages.asData?.value ?? const [];
    final unread = _unreadCount(msgList);
    final projCount = projects.asData?.value.length ?? 0;
    final loadingBadges =
        profile.isLoading || projects.isLoading || messages.isLoading;

    return DashboardShell(
      selectedIndex: tab,
      onSelect: (i) => setState(() => tab = i),
      menu: [
        const SidebarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        const SidebarItem(icon: Icons.person_outline, label: 'Profil Saya'),
        SidebarItem(
          icon: Icons.work_outline,
          label: 'Proyek',
          badge: loadingBadges ? '…' : '$projCount',
        ),
        const SidebarItem(
          icon: Icons.school_outlined,
          label: 'Skill & Pengalaman',
        ),
        SidebarItem(
          icon: Icons.mail_outline,
          label: 'Pesan',
          badge: loadingBadges ? '…' : '$unread',
        ),
      ],
      displayName:
          profile.asData?.value.fullName ?? auth.user?.username ?? 'Kreator',
      displayRole: profile.asData?.value.headline ?? 'Kreator Portofolio',
      unreadCount: unread,
      child: RefreshIndicator(
        onRefresh: () async => _refreshAll(),
        child: _body(first),
      ),
    );
  }

  Widget _body(String first) {
    if (tab == 1) return _profileTab();
    if (tab == 2) return _projectsTab();
    if (tab == 3) return _skillsTab();
    if (tab == 4) return _inboxTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Workspace portofolio',
          title: 'Halo, $first',
          subtitle:
              'Kelola karya terbaik dan tampilkan siapa dirimu kepada dunia.',
          actionLabel: 'Tambah proyek',
          onAction: () => setState(() => tab = 2),
        ),
        const SizedBox(height: 18),
        _profileCard(),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (_, c) {
            final wide = c.maxWidth > 860;
            final left = Column(
              children: [
                _latestProjects(),
                const SizedBox(height: 14),
                _miniStats(),
              ],
            );
            final right = Column(
              children: [
                _completeness(),
                const SizedBox(height: 14),
                _latestMessages(),
              ],
            );
            if (!wide) {
              return Column(
                children: [left, const SizedBox(height: 14), right],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: left),
                const SizedBox(width: 14),
                Expanded(flex: 5, child: right),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _profileCard() {
    final profile = ref.watch(myProfileProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: profile.when(
          data: (u) {
            final name = u.fullName ?? u.username;
            final initials = name.trim().isEmpty
                ? 'AR'
                : name
                      .trim()
                      .split(RegExp(r'\s+'))
                      .take(2)
                      .map((e) => e[0].toUpperCase())
                      .join();
            return Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: FolioColors.peachBg,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: FolioColors.peachInk,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(u.isPublished ? 'Published' : 'Draft'),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${u.headline ?? 'Product Designer'} · Jakarta, Indonesia',
                        style: const TextStyle(color: FolioColors.muted),
                      ),
                      Text(
                        'foliospace.id/${u.profileSlug ?? u.username.toLowerCase()}',
                        style: const TextStyle(
                          color: FolioColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          context.go('/u/${u.profileSlug ?? 'admin'}'),
                      child: const Text('Preview'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref
                              .read(apiServiceProvider)
                              .setPublish(!u.isPublished);
                          ref.invalidate(myProfileProvider);
                          _snack(
                            u.isPublished
                                ? 'Situs di-unpublish'
                                : 'Situs dipublish',
                          );
                        } catch (e) {
                          _snack(
                            _friendly(e, 'Gagal ubah status publish'),
                            error: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FolioColors.ink,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(u.isPublished ? 'Unpublish' : 'Buka situs'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const ProfileCardSkeleton(),
          error: (e, _) => Text(_friendly(e, 'Gagal memuat profil')),
        ),
      ),
    );
  }

  Widget _latestProjects() {
    final projects = ref.watch(myProjectsProvider);
    return SectionCard(
      title: 'Proyek terbaru',
      subtitle: 'Karya yang tampil di portofoliomu',
      trailing: TextButton(
        onPressed: () => setState(() => tab = 2),
        child: const Text('Kelola semua'),
      ),
      child: projects.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyCard(
              title: 'Belum ada proyek',
              subtitle:
                  'Tambahkan proyek pertamamu agar portofolio tampil menarik.',
            );
          }
          return Column(
            children: list.take(3).map((p) {
              final cat = (p.skills?.isNotEmpty == true)
                  ? p.skills!.first.name
                  : (p.status ?? 'Proyek');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: FolioColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: FolioColors.muted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            cat,
                            style: const TextStyle(
                              color: FolioColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.status ?? 'Aktif',
                            style: const TextStyle(
                              color: FolioColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: FolioColors.muted),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorCard(
          message: _friendly(e, 'Gagal memuat proyek'),
          onRetry: () => ref.invalidate(myProjectsProvider),
        ),
      ),
    );
  }

  Widget _miniStats() {
    final projects = ref.watch(myProjectsProvider);
    final skills = ref.watch(mySkillsProvider);
    final messages = ref.watch(myMessagesProvider);
    if (projects.isLoading || skills.isLoading || messages.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SkeletonBox(width: double.infinity, height: 48),
        ),
      );
    }
    final pc = projects.asData?.value.length ?? 0;
    final sc = skills.asData?.value.length ?? 0;
    final mc = messages.asData?.value.length ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            _mini('$sc', 'Total skill'),
            _vdiv(),
            _mini('$pc', 'Total proyek'),
            _vdiv(),
            _mini('$mc', 'Pesan masuk'),
          ],
        ),
      ),
    );
  }

  Widget _mini(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(
          v,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        Text(l, style: const TextStyle(color: FolioColors.muted, fontSize: 12)),
      ],
    ),
  );

  Widget _vdiv() => Container(width: 1, height: 36, color: FolioColors.border);

  Widget _completeness() {
    final profile = ref.watch(myProfileProvider);
    final skills = ref.watch(mySkillsProvider);
    final projects = ref.watch(myProjectsProvider);
    final exps = ref.watch(myExperiencesProvider);
    int pct = 20;
    final u = profile.asData?.value;
    final isLoading =
        profile.isLoading ||
        skills.isLoading ||
        projects.isLoading ||
        exps.isLoading;
    if (u != null) {
      if ((u.fullName ?? '').isNotEmpty) pct += 15;
      if ((u.headline ?? '').isNotEmpty) pct += 10;
      if ((u.bio ?? '').isNotEmpty) pct += 10;
      if ((skills.asData?.value.length ?? 0) > 0) pct += 15;
      if ((projects.asData?.value.length ?? 0) > 0) pct += 15;
      if ((exps.asData?.value.length ?? 0) > 0) pct += 10;
      if ((u.resumeUrl ?? '').isNotEmpty) pct += 5;
      pct = pct.clamp(5, 100);
    } else if (isLoading) {
      return const ListSkeleton(rows: 4);
    } else {
      pct = 20;
    }
    return SectionCard(
      title: 'Kelengkapan profil',
      subtitle: 'Sedikit lagi portofoliomu sempurna',
      trailing: Text(
        '$pct%',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFEEF0F6),
              valueColor: const AlwaysStoppedAnimation(FolioColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          _check('Informasi profil', (u?.fullName ?? '').isNotEmpty),
          _check('Proyek pilihan', (projects.asData?.value.length ?? 0) > 0),
          _check('Skill & keahlian', (skills.asData?.value.length ?? 0) > 0),
          _check('Pengalaman kerja', (exps.asData?.value.length ?? 0) > 0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Upload resume',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: TextButton(
              onPressed: () => setState(() => tab = 1),
              child: const Text('Lengkapi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _check(String t, bool done) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 20,
          color: done ? FolioColors.green : FolioColors.muted,
        ),
        const SizedBox(width: 10),
        Text(t),
      ],
    ),
  );

  Widget _messageTile(Map<String, dynamic> m, {bool full = false}) {
    final name = m['sender_name']?.toString() ?? 'Anonim';
    final content = m['content']?.toString() ?? '';
    final date = _fmtDate(m['created_at']);
    final unread = m['is_read'] != true;
    final ini = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((e) => e[0].toUpperCase())
              .join();
    final preview = full
        ? content
        : (content.length > 42 ? '${content.substring(0, 42)}...' : content);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: FolioColors.primarySoft,
            child: Text(
              ini,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: FolioColors.primary,
              ),
            ),
          ),
          if (unread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: FolioColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: FolioColors.muted, fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(preview, maxLines: full ? 3 : 1),
    );
  }

  Widget _latestMessages() {
    final messages = ref.watch(myMessagesProvider);
    return SectionCard(
      title: 'Pesan terbaru',
      subtitle: 'Dari pengunjung portofoliomu',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9D6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          messages.isLoading
              ? '…'
              : '${_unreadCount(messages.asData?.value ?? const [])} belum dibaca',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
      child: messages.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyCard(
              title: 'Belum ada pesan',
              subtitle:
                  'Pesan dari pengunjung portofoliomu akan tampil di sini.',
            );
          }
          return Column(
            children: list.take(3).map((m) => _messageTile(m)).toList(),
          );
        },
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorCard(
          message: _friendly(e, 'Gagal memuat pesan'),
          onRetry: () => ref.invalidate(myMessagesProvider),
        ),
      ),
    );
  }

  // ---------- Tab: Profil ----------

  Widget _profileTab() {
    final profile = ref.watch(myProfileProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Workspace portofolio',
          title: 'Profil Saya',
          subtitle: 'Atur identitas, slug publik, dan status publikasi.',
          actionLabel: 'Lihat publik',
          onAction: () {
            final slug = profile.asData?.value.profileSlug ?? 'admin';
            context.go('/u/$slug');
          },
        ),
        const SizedBox(height: 16),
        _profileCard(),
        const SizedBox(height: 14),
        profile.when(
          data: (u) => _ProfileForm(
            key: ValueKey(u.id),
            user: u,
            onSaved: () => ref.invalidate(myProfileProvider),
            onError: (msg) => _snack(msg, error: true),
            onSuccess: _snack,
          ),
          loading: () => const ListSkeleton(rows: 4),
          error: (e, _) => ErrorCard(
            message: _friendly(e, 'Gagal memuat profil'),
            onRetry: () => ref.invalidate(myProfileProvider),
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Proyek ----------

  Future<void> _saveProject({ProjectModel? existing}) async {
    final skills = ref.read(mySkillsProvider).asData?.value ?? const [];
    final payload = await showProjectDialog(
      context,
      project: existing,
      allSkills: skills,
    );
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.createMyProject(payload);
        _snack('Proyek ditambahkan');
      } else {
        await api.updateMyProject(existing.id, payload);
        _snack('Proyek diperbarui');
      }
      ref.invalidate(myProjectsProvider);
    } catch (e) {
      _snack(_friendly(e, 'Gagal simpan proyek'), error: true);
    }
  }

  Future<void> _deleteProject(ProjectModel p) async {
    if (!await confirmDelete(context, 'Proyek "${p.title}"')) return;
    try {
      await ref.read(apiServiceProvider).deleteMyProject(p.id);
      ref.invalidate(myProjectsProvider);
      _snack('Proyek dihapus');
    } catch (e) {
      _snack(_friendly(e, 'Gagal hapus proyek'), error: true);
    }
  }

  Future<void> _addProjectMedia(ProjectModel p) async {
    final data = await showProjectMediaDialog(context);
    if (data == null) return;
    try {
      await ref
          .read(apiServiceProvider)
          .addMyProjectMedia(
            p.id,
            mediaUrl: data['media_url']!,
            mediaType: data['media_type'] ?? 'image',
            caption: (data['caption'] ?? '').isEmpty ? null : data['caption'],
          );
      ref.invalidate(myProjectsProvider);
      _snack('Media ditambahkan ke "${p.title}"');
    } catch (e) {
      _snack(_friendly(e, 'Gagal tambah media'), error: true);
    }
  }

  Widget _projectsTab() {
    final projects = ref.watch(myProjectsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Workspace portofolio',
          title: 'Proyek',
          subtitle: 'Semua karya yang tampil di portofoliomu.',
          actionLabel: 'Tambah proyek',
          onAction: () => _saveProject(),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Daftar proyek',
          subtitle:
              'Dialog tambah/edit: title, slug, summary, status, live/github URL, skill_ids. Cover via URL cover, media via tombol +.',
          child: projects.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada proyek',
                  subtitle: 'Proyek akan tampil di sini.',
                );
              }
              return Column(
                children: list
                    .map(
                      (p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.image_outlined),
                        title: Text(p.title),
                        subtitle: Text(
                          '${p.slug} • ${p.status ?? '-'} • ${(p.media ?? []).length} media',
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (v) {
                            if (v == 'edit') {
                              _saveProject(existing: p);
                            } else if (v == 'media') {
                              _addProjectMedia(p);
                            } else if (v == 'delete') {
                              _deleteProject(p);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'media',
                              child: Text('Tambah media'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: _friendly(e, 'Gagal memuat proyek'),
              onRetry: () => ref.invalidate(myProjectsProvider),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Skill & Pengalaman ----------

  Future<void> _saveSkill({SkillModel? existing}) async {
    final payload = await showSkillDialog(context, skill: existing);
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.createMySkill(payload);
        _snack('Skill ditambahkan');
      } else {
        await api.updateMySkill(existing.id, payload);
        _snack('Skill diperbarui');
      }
      ref.invalidate(mySkillsProvider);
    } catch (e) {
      _snack(_friendly(e, 'Gagal simpan skill'), error: true);
    }
  }

  Future<void> _deleteSkill(SkillModel s) async {
    if (!await confirmDelete(context, 'Skill "${s.name}"')) return;
    try {
      await ref.read(apiServiceProvider).deleteMySkill(s.id);
      ref.invalidate(mySkillsProvider);
      _snack('Skill dihapus');
    } catch (e) {
      _snack(_friendly(e, 'Gagal hapus skill'), error: true);
    }
  }

  Future<void> _saveExperience({ExperienceModel? existing}) async {
    final payload = await showExperienceDialog(context, experience: existing);
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.createMyExperience(payload);
        _snack('Pengalaman ditambahkan');
      } else {
        await api.updateMyExperience(existing.id, payload);
        _snack('Pengalaman diperbarui');
      }
      ref.invalidate(myExperiencesProvider);
    } catch (e) {
      _snack(_friendly(e, 'Gagal simpan pengalaman'), error: true);
    }
  }

  Future<void> _deleteExperience(ExperienceModel e) async {
    if (!await confirmDelete(context, '"${e.role} @ ${e.company}"')) {
      return;
    }
    try {
      await ref.read(apiServiceProvider).deleteMyExperience(e.id);
      ref.invalidate(myExperiencesProvider);
      _snack('Pengalaman dihapus');
    } catch (err) {
      _snack(_friendly(err, 'Gagal hapus pengalaman'), error: true);
    }
  }

  String _expRange(ExperienceModel e) {
    String fmt(DateTime? d) =>
        d == null ? '?' : d.toIso8601String().substring(0, 10);
    final end = e.isCurrent ? 'kini' : fmt(e.endDate);
    return '${fmt(e.startDate)} → $end';
  }

  Widget _skillsTab() {
    final skills = ref.watch(mySkillsProvider);
    final exps = ref.watch(myExperiencesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Skill & keahlian',
          subtitle: 'Ketuk ikon pensil untuk edit (PATCH).',
          trailing: TextButton.icon(
            onPressed: () => _saveSkill(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah'),
          ),
          child: skills.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada skill',
                  subtitle: 'Tambahkan skill pertamamu.',
                );
              }
              return Column(
                children: list
                    .map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(s.name),
                        subtitle: Text(
                          '${s.category ?? 'Other'}${s.proficiencyLevel != null ? ' • ${s.proficiencyLevel}%' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _saveSkill(existing: s),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _deleteSkill(s),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: _friendly(e, 'Gagal memuat skill'),
              onRetry: () => ref.invalidate(mySkillsProvider),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Pengalaman kerja',
          subtitle: 'CRUD penuh: role, company, tanggal, is_current.',
          trailing: TextButton.icon(
            onPressed: () => _saveExperience(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah'),
          ),
          child: exps.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada pengalaman',
                  subtitle: 'Pengalaman kerja akan tampil di sini.',
                );
              }
              return Column(
                children: list
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(e.role),
                        subtitle: Text('${e.company} • ${_expRange(e)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => _saveExperience(existing: e),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () => _deleteExperience(e),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: _friendly(e, 'Gagal memuat pengalaman'),
              onRetry: () => ref.invalidate(myExperiencesProvider),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Tab: Inbox ----------

  Future<void> _markRead(Map<String, dynamic> m) async {
    final id = m['id'];
    if (id == null) return;
    try {
      await ref.read(apiServiceProvider).markMyMessageRead((id as num).toInt());
      ref.invalidate(myMessagesProvider);
      _snack('Pesan ditandai dibaca');
    } catch (e) {
      _snack(_friendly(e, 'Gagal tandai pesan'), error: true);
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> m) async {
    final id = m['id'];
    if (id == null) return;
    if (!await confirmDelete(
      context,
      'Pesan dari "${m['sender_name'] ?? 'Anonim'}"',
    )) {
      return;
    }
    try {
      await ref.read(apiServiceProvider).deleteMyMessage((id as num).toInt());
      ref.invalidate(myMessagesProvider);
      _snack('Pesan dihapus');
    } catch (e) {
      _snack(_friendly(e, 'Gagal hapus pesan'), error: true);
    }
  }

  Widget _inboxTab() {
    final messages = ref.watch(myMessagesProvider);
    return SectionCard(
      title: 'Pesan masuk',
      subtitle: 'Dari pengunjung portofoliomu',
      child: messages.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyCard(
              title: 'Belum ada pesan',
              subtitle: 'Pesan akan tampil di sini.',
            );
          }
          return Column(
            children: list
                .map(
                  (m) => Column(
                    children: [
                      _messageTile(m, full: true),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (m['is_read'] != true)
                            TextButton.icon(
                              onPressed: () => _markRead(m),
                              icon: const Icon(
                                Icons.mark_email_read_outlined,
                                size: 16,
                              ),
                              label: const Text('Tandai dibaca'),
                            ),
                          TextButton.icon(
                            onPressed: () => _deleteMessage(m),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Hapus'),
                          ),
                        ],
                      ),
                      const Divider(height: 8),
                    ],
                  ),
                )
                .toList(),
          );
        },
        loading: () => const ListSkeleton(rows: 4),
        error: (e, _) => ErrorCard(
          message: _friendly(e, 'Gagal memuat pesan'),
          onRetry: () => ref.invalidate(myMessagesProvider),
        ),
      ),
    );
  }
}

/// Form profil: full_name/headline/bio/profile_slug/avatar_url/resume_url
/// + toggle publish + ganti password. Upload file biner memakai
/// `uploadMyAvatar` (butuh MultipartFile/file-picker, belum diwired —
/// kolom URL menerima hasil upload); resume juga via URL karena BE
/// belum punya `POST /me/upload/resume` (hanya `/admin/upload/resume`).
class _ProfileForm extends ConsumerStatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;
  final void Function(String msg) onError;
  final void Function(String msg) onSuccess;

  const _ProfileForm({
    super.key,
    required this.user,
    required this.onSaved,
    required this.onError,
    required this.onSuccess,
  });

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final TextEditingController _fullName;
  late final TextEditingController _headline;
  late final TextEditingController _bio;
  late final TextEditingController _slug;
  late final TextEditingController _avatar;
  late final TextEditingController _resume;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fullName = TextEditingController(text: widget.user.fullName ?? '');
    _headline = TextEditingController(text: widget.user.headline ?? '');
    _bio = TextEditingController(text: widget.user.bio ?? '');
    _slug = TextEditingController(text: widget.user.profileSlug ?? '');
    _avatar = TextEditingController(text: widget.user.avatarUrl ?? '');
    _resume = TextEditingController(text: widget.user.resumeUrl ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _headline.dispose();
    _bio.dispose();
    _slug.dispose();
    _avatar.dispose();
    _resume.dispose();
    super.dispose();
  }

  String _friendly(Object e) {
    if (e is ApiException) {
      if (e.isNotFound) return 'Profil tidak ditemukan.';
      if (e.isRateLimited) {
        return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
      }
      return e.message;
    }
    return 'Gagal simpan profil';
  }

  String? _orNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(apiServiceProvider).updateMyProfile({
        'full_name': _orNull(_fullName),
        'headline': _orNull(_headline),
        'bio': _orNull(_bio),
        'profile_slug': _orNull(_slug),
        'avatar_url': _orNull(_avatar),
        'resume_url': _orNull(_resume),
      });
      widget.onSaved();
      widget.onSuccess('Profil disimpan');
    } catch (e) {
      widget.onError(_friendly(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePublish(bool published) async {
    try {
      await ref.read(apiServiceProvider).setPublish(!published);
      widget.onSaved();
      widget.onSuccess(published ? 'Situs di-unpublish' : 'Situs dipublish');
    } catch (e) {
      widget.onError(_friendly(e));
    }
  }

  Future<void> _changePassword() async {
    final pair = await showChangePasswordDialog(context);
    if (pair == null) return;
    try {
      await ref.read(authServiceProvider).changePassword(pair[0], pair[1]);
      widget.onSuccess('Password diganti');
    } catch (e) {
      widget.onError(_friendly(e));
    }
  }

  Widget _field(
    TextEditingController c,
    String label, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final published = widget.user.isPublished;
    return SectionCard(
      title: 'Edit profil',
      subtitle:
          'foliospace.id/${_slug.text.trim().isEmpty ? '-' : _slug.text.trim()}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_fullName, 'Nama lengkap', hint: 'misal: Budi Santoso'),
          _field(_headline, 'Headline', hint: 'misal: Product Designer'),
          _field(_bio, 'Bio', hint: 'Ceritakan dirimu...', maxLines: 3),
          _field(
            _slug,
            'Profile slug',
            hint: 'huruf-kecil-angka-strip, misal: budi-dev',
          ),
          _field(
            _avatar,
            'Avatar URL',
            hint: 'https://... (hasil upload avatar)',
          ),
          _field(
            _resume,
            'Resume URL',
            hint: 'https://... (hasil upload resume)',
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Publish situs'),
            subtitle: Text(
              published ? 'PUBLISHED — publik bisa melihat' : 'DRAFT',
            ),
            value: published,
            onChanged: (_) => _togglePublish(published),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_saving ? 'Menyimpan...' : 'Simpan profil'),
              ),
              OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock_outline, size: 18),
                label: const Text('Ganti password'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
