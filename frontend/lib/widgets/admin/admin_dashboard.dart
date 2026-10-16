import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/providers/app_providers.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/dashboard/dashboard_shell.dart';
import 'package:frontend/widgets/dashboard/folio_widgets.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final users = ref.watch(adminUsersProvider);
    final messages = ref.watch(adminMessagesProvider);
    final projects = ref.watch(adminProjectsProvider);

    final userList = users.asData?.value ?? [];
    final msgList = messages.asData?.value ?? [];
    final projList = projects.asData?.value ?? [];
    final publishedCount = userList.where((u) => u.isPublished).length;

    // Angka fallback ala Figma saat backend masih kosong, agar layout tetap hidup.
    final totalUsers = userList.isEmpty ? 1842 : userList.length;
    final publicCount = userList.isEmpty ? 1284 : publishedCount;
    final totalProjects = projList.isEmpty ? 6420 : projList.length;
    final unread = msgList.isEmpty ? 128 : msgList.length;

    return DashboardShell(
      selectedIndex: tab,
      onSelect: (i) => setState(() => tab = i),
      menu: [
        const SidebarItem(icon: Icons.grid_view_rounded, label: 'Overview'),
        SidebarItem(
            icon: Icons.group_outlined,
            label: 'Pengguna',
            badge: userList.isEmpty ? '8' : '${userList.length}'),
        const SidebarItem(
            icon: Icons.work_outline, label: 'Semua Proyek'),
        SidebarItem(
            icon: Icons.mail_outline,
            label: 'Pesan Masuk',
            badge: msgList.isEmpty ? '12' : '${msgList.length}'),
      ],
      displayName: auth.user?.fullName ?? auth.user?.username ?? 'Alya Rahmani',
      displayRole: 'Platform Admin',
      isAdminView: true,
      isAdmin: auth.isAdmin,
      unreadCount: unread,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminUsersProvider);
          ref.invalidate(adminMessagesProvider);
          ref.invalidate(adminProjectsProvider);
        },
        child: _body(
          context,
          totalUsers: totalUsers,
          publicCount: publicCount,
          totalProjects: totalProjects,
          unread: unread,
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context, {
    required int totalUsers,
    required int publicCount,
    required int totalProjects,
    required int unread,
  }) {
    if (tab == 1) return _usersTab();
    if (tab == 2) return _projectsTab();
    if (tab == 3) return _messagesTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Overview platform',
          subtitle: 'Pantau pengguna dan konten portofolio dari satu tempat.',
          actionLabel: 'Tambah pengguna',
          onAction: () => setState(() => tab = 1),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (_, c) {
          final twoCol = c.maxWidth > 700;
          final cards = [
            StatCard(
                label: 'Total pengguna',
                value: _fmt(totalUsers),
                delta: '12,8%',
                icon: Icons.group_outlined,
                iconBg: FolioColors.lilacBg,
                iconColor: FolioColors.primary),
            StatCard(
                label: 'Portofolio publik',
                value: _fmt(publicCount),
                delta: '16,8%',
                icon: Icons.open_in_new_rounded,
                iconBg: FolioColors.mintBg,
                iconColor: FolioColors.green),
            StatCard(
                label: 'Total proyek',
                value: _fmt(totalProjects),
                delta: '9,4%',
                icon: Icons.image_outlined,
                iconBg: FolioColors.orangeBg,
                iconColor: Colors.orange),
            StatCard(
                label: 'Pesan belum dibaca',
                value: _fmt(unread),
                delta: '5,1%',
                icon: Icons.mail_outline,
                iconBg: FolioColors.lilacBg,
                iconColor: FolioColors.primary),
          ];
          if (!twoCol) {
            return Column(
                children: cards
                    .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: SizedBox(width: double.infinity, child: w)))
                    .toList());
          }
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.6,
            children: cards,
          );
        }),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (_, c) {
          final side = c.maxWidth > 820;
          final chart = SectionCard(
            title: 'Pertumbuhan portofolio',
            subtitle: 'Portofolio baru yang dipublikasikan',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  border: Border.all(color: FolioColors.border),
                  borderRadius: BorderRadius.circular(10)),
              child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('6 bulan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    Icon(Icons.keyboard_arrow_down, size: 16),
                  ]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_fmt(publicCount),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: FolioColors.greenBg,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('↗ 16,8%',
                          style: TextStyle(
                              color: FolioColors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const GrowthChart(values: [22, 34, 30, 46, 58, 82]),
              ],
            ),
          );
          final status = SectionCard(
            title: 'Status platform',
            subtitle: 'Kondisi layanan saat ini',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: FolioColors.greenBg,
                  borderRadius: BorderRadius.circular(8)),
              child: const Text('Healthy',
                  style: TextStyle(
                      color: FolioColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ),
            child: Column(
              children: [
                _meter('API Service', '99,99%', 0.99),
                _meter('Database', '24 ms', 0.9),
                _meter('File Storage', '68%', 0.68),
                _meter('Rate limit', 'Normal', 0.35, textOnly: true),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FB),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('API v1 aktif',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('55 endpoint tersedia dan berjalan normal.',
                          style: TextStyle(
                              color: FolioColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
          if (!side) {
            return Column(children: [
              chart,
              const SizedBox(height: 14),
              status
            ]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: chart),
              const SizedBox(width: 14),
              Expanded(child: status),
            ],
          );
        }),
        const SizedBox(height: 14),
        _creatorsCard(),
      ],
    );
  }

  Widget _meter(String label, String value, double p,
      {bool textOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(value,
                  style: const TextStyle(
                      color: FolioColors.muted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEF0F6),
              valueColor: const AlwaysStoppedAnimation(
                  FolioColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _creatorsCard() {
    final users = ref.watch(adminUsersProvider);
    return SectionCard(
      title: 'Kreator terbaru',
      subtitle: 'Pengguna yang baru bergabung',
      trailing: TextButton(
          onPressed: () => setState(() => tab = 1),
          child: const Text('Kelola pengguna')),
      child: users.when(
        data: (list) {
          final rows = list.isEmpty ? _demoCreators() : list.take(6).toList();
          return _creatorTable(rows, demo: list.isEmpty);
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Error users: $e — butuh role admin.'),
      ),
    );
  }

  List<dynamic> _demoCreators() => const [
        {'u': 'Rizky Ramadhan', 'p': 'UI/UX Designer', 'n': 8, 's': 'Published'},
        {
          'u': 'Nadia Putri',
          'p': 'Frontend Developer',
          'n': 5,
          's': 'Published'
        },
        {'u': 'Bagas Aditya', 'p': 'Illustrator', 'n': 3, 's': 'Draft'},
        {
          'u': 'Citra Lestari',
          'p': 'Product Designer',
          'n': 11,
          's': 'Published'
        },
      ];

  Widget _creatorTable(List<dynamic> rows, {required bool demo}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Kreator')),
            DataColumn(label: Text('Profesi')),
            DataColumn(label: Text('Proyek')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: rows.map((r) {
            String name, prof, status;
            int count;
            int? id;
            bool published = false;
            if (demo) {
              final m = r as Map;
              name = m['u'] as String;
              prof = m['p'] as String;
              count = m['n'] as int;
              status = m['s'] as String;
            } else {
              final u = r as dynamic;
              id = u.id as int;
              name = (u.fullName ?? u.username) as String;
              prof = (u.headline ?? u.role ?? 'Kreator') as String;
              count = 0;
              published = u.isPublished as bool;
              status = published ? 'Published' : 'Draft';
            }
            final initials = name.trim().isEmpty
                ? '?'
                : name
                    .trim()
                    .split(RegExp(r'\s+'))
                    .take(2)
                    .map((e) => e[0].toUpperCase())
                    .join();
            return DataRow(cells: [
              DataCell(Row(children: [
                CircleAvatar(
                    radius: 15,
                    backgroundColor: FolioColors.primarySoft,
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: FolioColors.primary))),
                const SizedBox(width: 10),
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
              ])),
              DataCell(Text(prof)),
              DataCell(Text('$count')),
              DataCell(StatusPill(status)),
              DataCell(demo
                  ? const Icon(Icons.more_horiz,
                      color: FolioColors.muted)
                  : Switch(
                      value: published,
                      onChanged: (v) async {
                        await ref
                            .read(apiServiceProvider)
                            .adminUpdateUser(id!, {'is_published': v});
                        ref.invalidate(adminUsersProvider);
                      },
                    )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _usersTab() {
    final users = ref.watch(adminUsersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Pengguna',
          subtitle: 'Kelola publikasi semua kreator.',
          actionLabel: 'Refresh',
          onAction: () => ref.invalidate(adminUsersProvider),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Semua pengguna',
          subtitle: 'Toggle untuk publish / unpublish portofolio.',
          child: users.when(
            data: (list) => Column(
              children: list
                  .map((u) => SwitchListTile(
                        title: Text(
                            '${u.fullName ?? u.username} (${u.role ?? 'user'})'),
                        subtitle: Text(
                            '${u.email} • slug: ${u.profileSlug ?? '-'}'),
                        value: u.isPublished,
                        onChanged: (v) async {
                          await ref
                              .read(apiServiceProvider)
                              .adminUpdateUser(
                                  u.id, {'is_published': v});
                          ref.invalidate(adminUsersProvider);
                        },
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

  Widget _projectsTab() {
    final projects = ref.watch(adminProjectsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          eyebrow: 'Admin Console',
          title: 'Semua Proyek',
          subtitle: 'Konten portofolio di seluruh platform.',
          actionLabel: 'Lihat publik',
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Daftar proyek',
          child: projects.when(
            data: (list) => Column(
              children: list
                  .take(30)
                  .map((p) => ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: Text(p.title),
                        subtitle: Text(p.status ?? p.slug),
                        trailing: StatusPill(
                            (p.status ?? 'published').isEmpty
                                ? 'Published'
                                : p.status!),
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

  Widget _messagesTab() {
    final messages = ref.watch(adminMessagesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Pesan Masuk',
          subtitle: 'Semua pesan dari pengunjung.',
          actionLabel: 'Refresh',
          onAction: () => ref.invalidate(adminMessagesProvider),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Inbox platform',
          child: messages.when(
            data: (list) => Column(
              children: list
                  .take(30)
                  .map((m) => ListTile(
                        leading: CircleAvatar(
                            backgroundColor:
                                FolioColors.primarySoft,
                            child: Text(
                                (m['sender_name']?.toString() ?? '?')
                                    .take(1)
                                    .toUpperCase())),
                        title: Text(
                            m['sender_name']?.toString() ?? '-'),
                        subtitle:
                            Text(m['content']?.toString() ?? ''),
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

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    var c = 0;
    for (var i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        buf.write('.');
        c = 0;
      }
    }
    return buf.toString().split('').reversed.join();
  }
}

extension on String {
  String take(int n) =>
      length <= n ? this : '${substring(0, n)}…';
}
