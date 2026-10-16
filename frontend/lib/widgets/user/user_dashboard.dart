import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/dashboard/dashboard_shell.dart';
import 'package:frontend/widgets/dashboard/folio_widgets.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final profile = ref.watch(myProfileProvider);
    final projects = ref.watch(myProjectsProvider);
    final messages = ref.watch(myMessagesProvider);

    final name =
        profile.asData?.value.fullName ?? auth.user?.username ?? 'Alya';
    final first = name.trim().split(RegExp(r'\s+')).first;
    final msgCount = messages.asData?.value.length ?? 3;
    final projCount = projects.asData?.value.length ?? 6;

    return DashboardShell(
      selectedIndex: tab,
      onSelect: (i) => setState(() => tab = i),
      menu: [
        const SidebarItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
        const SidebarItem(icon: Icons.person_outline, label: 'Profil Saya'),
        SidebarItem(
            icon: Icons.work_outline,
            label: 'Proyek',
            badge: '$projCount'),
        const SidebarItem(
            icon: Icons.school_outlined, label: 'Skill & Pengalaman'),
        SidebarItem(
            icon: Icons.mail_outline,
            label: 'Pesan',
            badge: '$msgCount'),
      ],
      displayName: profile.asData?.value.fullName ??
          auth.user?.username ??
          'Alya Rahmani',
      displayRole: profile.asData?.value.headline ?? 'Product Designer',
      isAdminView: false,
      isAdmin: auth.isAdmin,
      unreadCount: msgCount,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myProfileProvider);
          ref.invalidate(myProjectsProvider);
          ref.invalidate(mySkillsProvider);
          ref.invalidate(myExperiencesProvider);
          ref.invalidate(myMessagesProvider);
        },
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
        LayoutBuilder(builder: (_, c) {
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
            return Column(children: [
              left,
              const SizedBox(height: 14),
              right,
            ]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: left),
              const SizedBox(width: 14),
              Expanded(flex: 5, child: right),
            ],
          );
        }),
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
                  child: Text(initials,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: FolioColors.peachInk)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                          ),
                          const SizedBox(width: 8),
                          StatusPill(u.isPublished
                              ? 'Published'
                              : 'Draft'),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                          '${u.headline ?? 'Product Designer'} · Jakarta, Indonesia',
                          style: const TextStyle(
                              color: FolioColors.muted)),
                      Text(
                          'foliospace.id/${u.profileSlug ?? u.username.toLowerCase()}',
                          style: const TextStyle(
                              color: FolioColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                        onPressed: () => context.go(
                            '/u/${u.profileSlug ?? 'admin'}'),
                        child: const Text('Preview')),
                    ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(apiServiceProvider)
                            .setPublish(!u.isPublished);
                        ref.invalidate(myProfileProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FolioColors.ink,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(u.isPublished
                          ? 'Unpublish'
                          : 'Buka situs'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () =>
              const LinearProgressIndicator(),
          error: (e, _) => Text('Profil: $e'),
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
          child: const Text('Kelola semua')),
      child: projects.when(
        data: (list) {
          if (list.isEmpty) {
            return Column(
              children: _demoProjects().map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      border: Border.all(color: FolioColors.border),
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: const Color(0xFFEEF0F6),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.image_outlined,
                            color: FolioColors.muted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(p['t']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text(p['c']!,
                                style: const TextStyle(
                                    color: FolioColors.muted,
                                    fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                                '👁 ${p['v']}   •   ${p['a']}',
                                style: const TextStyle(
                                    color: FolioColors.muted,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: FolioColors.muted),
                    ],
                  ),
                );
              }).toList(),
            );
          }
          return Column(
            children: list.take(3).map((p) {
              final cat = (p.skills?.isNotEmpty == true)
                  ? p.skills!.first.name
                  : (p.status ?? 'Product Design');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    border: Border.all(color: FolioColors.border),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: const Color(0xFFEEF0F6),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.image_outlined,
                          color: FolioColors.muted),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Text(cat,
                              style: const TextStyle(
                                  color: FolioColors.muted,
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(p.status ?? 'Aktif',
                              style: const TextStyle(
                                  color: FolioColors.muted,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: FolioColors.muted),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  List<Map<String, String>> _demoProjects() => const [
        {
          't': 'Nara Banking App',
          'c': 'UI/UX Design',
          'v': '1.2K',
          'a': '2 hari lalu'
        },
        {
          't': 'Kelana Travel',
          'c': 'Web Design',
          'v': '864',
          'a': '5 hari lalu'
        },
        {
          't': 'Luma Design System',
          'c': 'Product Design',
          'v': '642',
          'a': '1 minggu lalu'
        },
      ];

  Widget _miniStats() {
    final projects = ref.watch(myProjectsProvider);
    final messages = ref.watch(myMessagesProvider);
    final pc = projects.asData?.value.length ?? 6;
    final mc = messages.asData?.value.length ?? 24;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            _mini('4.820', 'Total tayangan'),
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
        child: Column(children: [
          Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18)),
          Text(l,
              style: const TextStyle(
                  color: FolioColors.muted, fontSize: 12)),
        ]),
      );

  Widget _vdiv() =>
      Container(width: 1, height: 36, color: FolioColors.border);

  Widget _completeness() {
    final profile = ref.watch(myProfileProvider);
    final skills = ref.watch(mySkillsProvider);
    final projects = ref.watch(myProjectsProvider);
    final exps = ref.watch(myExperiencesProvider);
    int pct = 20;
    final u = profile.asData?.value;
    if (u != null) {
      if ((u.fullName ?? '').isNotEmpty) pct += 15;
      if ((u.headline ?? '').isNotEmpty) pct += 10;
      if ((u.bio ?? '').isNotEmpty) pct += 10;
      if ((skills.asData?.value.length ?? 0) > 0) pct += 15;
      if ((projects.asData?.value.length ?? 0) > 0) pct += 15;
      if ((exps.asData?.value.length ?? 0) > 0) pct += 10;
      if ((u.resumeUrl ?? '').isNotEmpty) pct += 5;
      pct = pct.clamp(5, 100);
    } else {
      pct = 85;
    }
    return SectionCard(
      title: 'Kelengkapan profil',
      subtitle: 'Sedikit lagi portofoliomu sempurna',
      trailing: Text('$pct%',
          style: const TextStyle(fontWeight: FontWeight.w800)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFEEF0F6),
              valueColor: const AlwaysStoppedAnimation(
                  FolioColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          _check('Informasi profil', (u?.fullName ?? '').isNotEmpty),
          _check('Proyek pilihan',
              (projects.asData?.value.length ?? 1) > 0),
          _check('Skill & keahlian',
              (skills.asData?.value.length ?? 1) > 0),
          _check('Pengalaman kerja',
              (exps.asData?.value.length ?? 0) > 0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Upload resume',
                style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: TextButton(
                onPressed: () => _editSlug(context, ref,
                    profile.asData?.value.profileSlug),
                child: const Text('Lengkapi')),
          ),
        ],
      ),
    );
  }

  Widget _check(String t, bool done) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: done
                  ? FolioColors.green
                  : FolioColors.muted),
          const SizedBox(width: 10),
          Text(t),
        ]),
      );

  Widget _latestMessages() {
    final messages = ref.watch(myMessagesProvider);
    return SectionCard(
      title: 'Pesan terbaru',
      subtitle: 'Dari pengunjung portofoliomu',
      trailing: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: const Color(0xFFFFE9D6),
            borderRadius: BorderRadius.circular(8)),
        child: Text(
            '${messages.asData?.value.length ?? 3} baru',
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      child: messages.when(
        data: (list) {
          final items = list.isEmpty
              ? _demoMessages()
                  .map((e) => {
                        'sender_name': e['sender_name']!,
                        'content': e['content']!,
                        'time': e['time']!,
                      })
                  .toList()
              : list.take(3).map((e) => {
                    'sender_name':
                        (e['sender_name']?.toString() ?? 'Anonim'),
                    'content': (e['content']?.toString() ?? ''),
                    'time': (e['time']?.toString() ?? 'baru'),
                  }).toList();
          return Column(
            children: items.map((m) {
              final name = m['sender_name']!;
              final content = m['content']!;
              final time = m['time']!;
              final ini = name.trim().isEmpty
                  ? '?'
                  : name
                      .trim()
                      .split(RegExp(r'\s+'))
                      .take(2)
                      .map((e) => e[0].toUpperCase())
                      .join();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                    backgroundColor:
                        FolioColors.primarySoft,
                    child: Text(ini,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: FolioColors.primary))),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                subtitle: Text(
                    content.length > 42
                        ? '${content.substring(0, 42)}...'
                        : content,
                    maxLines: 1),
                trailing: Text(time,
                    style: const TextStyle(
                        color: FolioColors.muted,
                        fontSize: 12)),
              );
            }).toList(),
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  List<Map<String, String>> _demoMessages() => const [
        {
          'sender_name': 'Dimas Saputra',
          'content': 'Tertarik bekerja sama untuk proyek...',
          'time': '10m'
        },
        {
          'sender_name': 'Sarah Wijaya',
          'content': 'Halo Alya, saya melihat proyek Nara...',
          'time': '2j'
        },
        {
          'sender_name': 'Kevin Studio',
          'content': 'Apakah kamu tersedia bulan depan?',
          'time': '1h'
        },
      ];

  Widget _profileTab() {
    final profile = ref.watch(myProfileProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Workspace portofolio',
          title: 'Profil Saya',
          subtitle: 'Atur slug publik dan status publikasi.',
          actionLabel: 'Lihat publik',
          onAction: () {
            final slug = profile.asData?.value.profileSlug ?? 'admin';
            context.go('/u/$slug');
          },
        ),
        const SizedBox(height: 16),
        _profileCard(),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Edit slug',
          subtitle: 'Alamat publik foliospace.id/slug-kamu',
          trailing: TextButton(
              onPressed: () => _editSlug(context, ref,
                  profile.asData?.value.profileSlug),
              child: const Text('Edit')),
          child: profile.when(
            data: (u) => Text(
                'slug: ${u.profileSlug ?? '-'} • ${u.isPublished ? 'PUBLISHED' : 'DRAFT'}'),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('$e'),
          ),
        ),
      ],
    );
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
          onAction: () {},
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Daftar proyek',
          child: projects.when(
            data: (list) => Column(
              children: list
                  .map((p) => ListTile(
                        leading: const Icon(
                            Icons.image_outlined),
                        title: Text(p.title),
                        subtitle: Text(p.status ?? ''),
                        trailing: IconButton(
                          icon: const Icon(
                              Icons.delete_outline),
                          onPressed: () async {
                            await ref
                                .read(apiServiceProvider)
                                .deleteMyProject(p.id);
                            ref.invalidate(
                                myProjectsProvider);
                          },
                        ),
                      ))
                  .toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
      ],
    );
  }

  Widget _skillsTab() {
    final skills = ref.watch(mySkillsProvider);
    final exps = ref.watch(myExperiencesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Skill & keahlian',
          trailing: TextButton.icon(
            onPressed: () => _addSkill(context, ref),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Tambah'),
          ),
          child: skills.when(
            data: (list) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: list
                  .map((s) => Chip(
                        label: Text(s.name),
                        onDeleted: () async {
                          await ref
                              .read(apiServiceProvider)
                              .deleteMySkill(s.id);
                          ref.invalidate(mySkillsProvider);
                        },
                      ))
                  .toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Pengalaman kerja',
          child: exps.when(
            data: (list) => Column(
              children: list
                  .map((e) => ListTile(
                        title: Text(e.role),
                        subtitle: Text(e.company),
                      ))
                  .toList(),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
          ),
        ),
      ],
    );
  }

  Widget _inboxTab() {
    final messages = ref.watch(myMessagesProvider);
    return SectionCard(
      title: 'Pesan masuk',
      subtitle: 'Dari pengunjung portofoliomu',
      child: messages.when(
        data: (list) => Column(
          children: list
              .map((m) => ListTile(
                    title: Text(
                        m['sender_name']?.toString() ?? 'Anonim'),
                    subtitle:
                        Text(m['content']?.toString() ?? ''),
                  ))
              .toList(),
        ),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }

  Future<void> _editSlug(
      BuildContext context, WidgetRef ref, String? current) async {
    final c = TextEditingController(text: current ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit profile_slug'),
        content: TextField(
            controller: c,
            decoration: const InputDecoration(
                hintText: 'misal: budi-dev')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan')),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(apiServiceProvider)
          .updateMyProfile({'profile_slug': c.text.trim()});
      ref.invalidate(myProfileProvider);
    }
  }

  Future<void> _addSkill(BuildContext context, WidgetRef ref) async {
    final c = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Skill baru'),
        content: TextField(
            controller: c,
            decoration: const InputDecoration(
                hintText: 'misal: Flutter')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tambah')),
        ],
      ),
    );
    if (ok == true && c.text.trim().isNotEmpty) {
      await ref
          .read(apiServiceProvider)
          .createMySkill({'name': c.text.trim()});
      ref.invalidate(mySkillsProvider);
    }
  }
}
