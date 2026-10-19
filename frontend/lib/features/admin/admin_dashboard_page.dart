import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard_me/dashboard_shell.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';
import 'package:frontend/shared/widgets/errors.dart';
import 'package:frontend/shared/widgets/folio_widgets.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int tab = 0;
  int? _ownerFilter;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Filter sederhana untuk search bar di topbar (case-insensitive).
  bool _hit(List<String?> fields) =>
      _query.isEmpty ||
      fields.any((f) => f?.toLowerCase().contains(_query) ?? false);

  List<UserModel> _filterUsers(List<UserModel> list) => _query.isEmpty
      ? list
      : list
          .where((u) => _hit([
                u.fullName,
                u.username,
                u.email,
                u.profileSlug,
              ]))
          .toList(growable: false);

  List<ProjectModel> _filterProjects(List<ProjectModel> list) => _query.isEmpty
      ? list
      : list
          .where((p) => _hit([p.title, p.slug]))
          .toList(growable: false);

  List<Map<String, dynamic>> _filterMessages(
          List<Map<String, dynamic>> list) =>
      _query.isEmpty
          ? list
          : list
              .where((m) => _hit([
                    m['sender_name']?.toString(),
                    m['sender_email']?.toString(),
                    m['content']?.toString(),
                  ]))
              .toList(growable: false);

  Widget _noResult(String what) => EmptyCard(
        title: 'Tidak ada hasil',
        subtitle: 'Tidak ada $what yang cocok dengan pencarian "$_query".',
      );

  /// Lompat ke tab Pesan Masuk dari lonceng notifikasi; bersihkan query
  /// agar pesan yang baru dibuka tidak tersaring.
  void _goMessages() {
    _search.clear();
    setState(() {
      _query = '';
      tab = 3;
    });
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  void _refreshAll() {
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminMessagesProvider);
    ref.invalidate(adminProjectsProvider);
    ref.invalidate(adminProjectsFilteredProvider);
    ref.invalidate(adminHealthProvider);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final users = ref.watch(adminUsersProvider);
    final messages = ref.watch(adminMessagesProvider);
    final projects = _ownerFilter == null
        ? ref.watch(adminProjectsProvider)
        : ref.watch(adminProjectsFilteredProvider(_ownerFilter));

    final userList = users.asData?.value ?? [];
    final msgList = messages.asData?.value ?? [];
    final projList = projects.asData?.value ?? [];
    final publishedCount = userList.where((u) => u.isPublished).length;
    final unread = msgList.where((m) => m['is_read'] != true).length;
    final isLoading =
        users.isLoading || messages.isLoading || projects.isLoading;

    return DashboardShell(
      selectedIndex: tab,
      onSelect: (i) => setState(() => tab = i),
      menu: [
        const SidebarItem(icon: Icons.grid_view_rounded, label: 'Overview'),
        SidebarItem(
          icon: Icons.group_outlined,
          label: 'Pengguna',
          badge: users.asData == null ? '…' : '${userList.length}',
        ),
        const SidebarItem(icon: Icons.work_outline, label: 'Semua Proyek'),
        SidebarItem(
          icon: Icons.mail_outline,
          label: 'Pesan Masuk',
          badge: messages.asData == null ? '…' : '${msgList.length}',
        ),
      ],
      displayName: auth.user?.fullName ?? auth.user?.username ?? 'Admin',
      displayRole: 'Platform Admin',
      avatarUrl: auth.user?.avatarUrl,
      unreadCount: unread,
      searchController: _search,
      onSearch: (q) => setState(() => _query = q.trim().toLowerCase()),
      unreadMessages:
          msgList.where((m) => m['is_read'] != true).toList(),
      onOpenNotification: (_) => _goMessages(),
      onOpenInbox: _goMessages,
      child: RefreshIndicator(
        onRefresh: () async => _refreshAll(),
        child: _body(
          totalUsers: userList.length,
          publicCount: publishedCount,
          totalProjects: projList.length,
          unread: unread,
          isLoading: isLoading,
        ),
      ),
    );
  }

  Widget _body({
    required int totalUsers,
    required int publicCount,
    required int totalProjects,
    required int unread,
    required bool isLoading,
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
          actionLabel: 'Kelola pengguna',
          onAction: () => setState(() => tab = 1),
        ),
        const SizedBox(height: 20),
        if (isLoading)
          const StatCardsSkeleton()
        else
          LayoutBuilder(
            builder: (_, c) {
              final twoCol = c.maxWidth > 700;
              final cards = [
                StatCard(
                  label: 'Total pengguna',
                  value: _fmt(totalUsers),
                  icon: Icons.group_outlined,
                  iconBg: FolioColors.lilacBg,
                  iconColor: FolioColors.primary,
                ),
                StatCard(
                  label: 'Portofolio publik',
                  value: _fmt(publicCount),
                  icon: Icons.open_in_new_rounded,
                  iconBg: FolioColors.mintBg,
                  iconColor: FolioColors.green,
                ),
                StatCard(
                  label: 'Total proyek',
                  value: _fmt(totalProjects),
                  icon: Icons.image_outlined,
                  iconBg: FolioColors.orangeBg,
                  iconColor: Colors.orange,
                ),
                StatCard(
                  label: 'Pesan belum dibaca',
                  value: _fmt(unread),
                  icon: Icons.mail_outline,
                  iconBg: FolioColors.lilacBg,
                  iconColor: FolioColors.primary,
                ),
              ];
              if (!twoCol) {
                return Column(
                  children: cards
                      .map(
                        (w) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: SizedBox(width: double.infinity, child: w),
                        ),
                      )
                      .toList(),
                );
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
            },
          ),
        const SizedBox(height: 14),
        if (isLoading) ...[
          const TableSkeleton(rows: 4),
        ] else ...[
          LayoutBuilder(
            builder: (_, c) {
              final side = c.maxWidth > 820;
              final summary = _contentSummaryCard();
              final status = _statusCard();
              if (!side) {
                return Column(
                  children: [summary, const SizedBox(height: 14), status],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: summary),
                  const SizedBox(width: 14),
                  Expanded(child: status),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          _creatorsCard(),
        ],
      ],
    );
  }

  /// Ringkasan konten berbasis data nyata (bukan angka dummy).
  Widget _contentSummaryCard() {
    final users = ref.watch(adminUsersProvider).asData?.value ?? [];
    final projects = _ownerFilter == null
        ? ref.watch(adminProjectsProvider).asData?.value ?? []
        : ref
                  .watch(adminProjectsFilteredProvider(_ownerFilter))
                  .asData
                  ?.value ??
              [];
    final publishedProjects = projects
        .where((p) => p.status == 'published')
        .length;
    final draftProjects = projects.length - publishedProjects;
    final publishedUsers = users.where((u) => u.isPublished).length;
    return SectionCard(
      title: 'Ringkasan konten',
      subtitle: 'Komposisi konten saat ini',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _barRow(
            'Proyek published',
            publishedProjects,
            projects.length,
            FolioColors.green,
          ),
          _barRow(
            'Proyek draft',
            draftProjects,
            projects.length,
            FolioColors.muted,
          ),
          const SizedBox(height: 6),
          _barRow(
            'Portofolio publik',
            publishedUsers,
            users.length,
            FolioColors.primary,
          ),
          _barRow(
            'Portofolio draft',
            users.length - publishedUsers,
            users.length,
            FolioColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _barRow(String label, int value, int total, Color color) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                '$value dari $total',
                style: const TextStyle(
                  color: FolioColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: FolioColors.primarySoft,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  /// Status platform dari GET /health (best-effort, tanpa angka palsu).
  Widget _statusCard() {
    final health = ref.watch(adminHealthProvider);
    final Widget badge;
    final String description;
    switch (health) {
      case AsyncData(:final value):
        if (value) {
          badge = _pill('Terjangkau', FolioColors.greenBg, FolioColors.green);
          description = 'Backend merespons GET /health dengan status ok.';
        } else {
          badge = _pill(
            'Respons tidak dikenal',
            FolioColors.orangeBg,
            Colors.orange.shade800,
          );
          description = 'Backend merespons, tetapi format tidak sesuai.';
        }
      case AsyncError():
        badge = _pill(
          'Tidak terjangkau',
          Colors.red.shade50,
          Colors.red.shade700,
        );
        description =
            'Tidak dapat menghubungi backend. Periksa koneksi atau server.';
      default:
        badge = _pill('Memeriksa…', const Color(0xFFF1F2F7), FolioColors.muted);
        description = 'Sedang memeriksa status backend.';
    }
    return SectionCard(
      title: 'Status platform',
      subtitle: 'Kondisi layanan saat ini',
      trailing: badge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FolioColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'API v1',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: FolioColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => ref.invalidate(adminHealthProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Periksa ulang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );

  Widget _creatorsCard() {
    final users = ref.watch(adminUsersProvider);
    return SectionCard(
      title: 'Kreator terbaru',
      subtitle: 'Pengguna yang baru bergabung',
      trailing: TextButton(
        onPressed: () => setState(() => tab = 1),
        child: const Text('Kelola pengguna'),
      ),
      child: users.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyCard(
              title: 'Belum ada kreator',
              subtitle:
                  'Data pengguna akan muncul di sini setelah ada yang mendaftar.',
            );
          }
          return _creatorTable(list.take(6).toList());
        },
        loading: () => const TableSkeleton(rows: 4),
        error: (e, _) => ErrorCard(
          message: friendlyError(e, 'Gagal memuat pengguna'),
          onRetry: () => ref.invalidate(adminUsersProvider),
        ),
      ),
    );
  }

  Widget _creatorTable(List<UserModel> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 700),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Kreator')),
            DataColumn(label: Text('Profesi')),
            DataColumn(label: Text('Slug')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Publikasi')),
          ],
          rows: rows.map((u) {
            final name = u.fullName ?? u.username;
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: FolioColors.primarySoft,
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: FolioColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(u.headline ?? u.role ?? '-')),
                DataCell(Text(u.profileSlug ?? '-')),
                DataCell(StatusPill(u.isPublished ? 'Published' : 'Draft')),
                DataCell(
                  Switch(
                    value: u.isPublished,
                    onChanged: (v) => _setUserField(u.id, {'is_published': v}),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _setUserField(int id, Map<String, dynamic> patch) async {
    try {
      await ref.read(apiServiceProvider).adminUpdateUser(id, patch);
      ref.invalidate(adminUsersProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal update user'), error: true);
    }
  }

  Future<void> _createUser() async {
    final payload = await showAdminUserDialog(context);
    if (payload == null) return;
    try {
      await ref.read(apiServiceProvider).adminCreateUser(payload);
      ref.invalidate(adminUsersProvider);
      _snack('User dibuat');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal buat user'), error: true);
    }
  }

  Widget _usersTab() {
    final users = ref.watch(adminUsersProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Pengguna',
          subtitle: 'Kelola publikasi, status aktif, dan role kreator.',
          actionLabel: 'Tambah user',
          onAction: _createUser,
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Semua pengguna',
          subtitle: 'Toggle publikasi, aktif/nonaktif, dan role lewat menu ⋮.',
          child: users.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada pengguna',
                  subtitle: 'Pengguna baru akan tampil di sini.',
                );
              }
              final filtered = _filterUsers(list);
              if (filtered.isEmpty) return _noResult('pengguna');
              return Column(
                children: filtered
                    .map(
                      (u) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: FolioColors.primarySoft,
                          child: Text(
                            _initials(u.fullName ?? u.username),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: FolioColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          '${u.fullName ?? u.username} (${u.role ?? 'user'})',
                        ),
                        subtitle: Text(
                          '${u.email} • slug: ${u.profileSlug ?? '-'}'
                          '${u.isActive ? '' : ' • nonaktif'}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: u.isPublished
                                  ? 'Sembunyikan portofolio'
                                  : 'Publikasikan portofolio',
                              child: Switch(
                                value: u.isPublished,
                                onChanged: (v) =>
                                    _setUserField(u.id, {'is_published': v}),
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (v) {
                                if (v == 'active') {
                                  _setUserField(u.id, {
                                    'is_active': !u.isActive,
                                  });
                                }
                                if (v == 'role') {
                                  _setUserField(u.id, {
                                    'role': u.isAdmin ? 'user' : 'admin',
                                  });
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'active',
                                  child: Text(
                                    u.isActive
                                        ? 'Nonaktifkan akun'
                                        : 'Aktifkan akun',
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'role',
                                  child: Text(
                                    u.isAdmin
                                        ? 'Jadikan user'
                                        : 'Jadikan admin',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const TableSkeleton(rows: 5),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat pengguna'),
              onRetry: () => ref.invalidate(adminUsersProvider),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createProject() async {
    final payload = await showProjectDialog(context);
    if (payload == null) return;
    try {
      await ref.read(apiServiceProvider).adminCreateProject(payload);
      ref.invalidate(adminProjectsProvider);
      ref.invalidate(adminProjectsFilteredProvider);
      _snack('Proyek dibuat');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal buat proyek'), error: true);
    }
  }

  Future<void> _editProject(ProjectModel p) async {
    final payload = await showProjectDialog(context, project: p);
    if (payload == null) return;
    try {
      await ref.read(apiServiceProvider).adminUpdateProject(p.id, payload);
      ref.invalidate(adminProjectsProvider);
      ref.invalidate(adminProjectsFilteredProvider);
      _snack('Proyek diperbarui');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal update proyek'), error: true);
    }
  }

  Future<void> _deleteProject(ProjectModel p) async {
    if (!await confirmDelete(context, 'Proyek "${p.title}"')) return;
    try {
      await ref.read(apiServiceProvider).adminDeleteProject(p.id);
      ref.invalidate(adminProjectsProvider);
      ref.invalidate(adminProjectsFilteredProvider);
      _snack('Proyek dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus proyek'), error: true);
    }
  }

  Future<void> _addProjectMedia(ProjectModel p) async {
    final data = await showProjectMediaDialog(context);
    if (data == null) return;
    try {
      await ref
          .read(apiServiceProvider)
          .adminAddProjectMedia(
            p.id,
            mediaUrl: data['media_url']!,
            mediaType: data['media_type'] ?? 'image',
            caption: (data['caption']?.isEmpty ?? true)
                ? null
                : data['caption'],
          );
      _snack('Media ditambahkan');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal tambah media'), error: true);
    }
  }

  Widget _projectsTab() {
    final users = ref.watch(adminUsersProvider).asData?.value ?? [];
    final projects = _ownerFilter == null
        ? ref.watch(adminProjectsProvider)
        : ref.watch(adminProjectsFilteredProvider(_ownerFilter));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Semua Proyek',
          subtitle: 'Konten portofolio di seluruh platform.',
          actionLabel: 'Tambah proyek',
          onAction: _createProject,
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Filter kreator',
          child: DropdownButtonFormField<int?>(
            initialValue: _ownerFilter,
            decoration: const InputDecoration(
              labelText: 'Pemilik proyek',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Semua kreator'),
              ),
              ...users.map(
                (u) => DropdownMenuItem<int?>(
                  value: u.id,
                  child: Text(u.fullName ?? u.username),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _ownerFilter = v),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Daftar proyek',
          child: projects.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada proyek',
                  subtitle: 'Proyek kreator akan tampil di sini.',
                );
              }
              final filtered = _filterProjects(list);
              if (filtered.isEmpty) return _noResult('proyek');
              return Column(
                children: filtered
                    .take(50)
                    .map(
                      (p) => ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: Text(p.title),
                        subtitle: Text('slug: ${p.slug} • ${p.status ?? '-'}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') {
                              _editProject(p);
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
            loading: () => const ListSkeleton(rows: 5),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat proyek'),
              onRetry: () {
                ref.invalidate(adminProjectsProvider);
                ref.invalidate(adminProjectsFilteredProvider);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markRead(int id) async {
    try {
      await ref.read(apiServiceProvider).adminMarkMessageRead(id);
      ref.invalidate(adminMessagesProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal tandai pesan'), error: true);
    }
  }

  Future<void> _deleteMessage(Map<String, dynamic> m) async {
    if (!await confirmDelete(
      context,
      'Pesan dari "${m['sender_name'] ?? 'pengirim'}"',
    )) {
      return;
    }
    try {
      await ref
          .read(apiServiceProvider)
          .adminDeleteMessage((m['id'] as num).toInt());
      ref.invalidate(adminMessagesProvider);
      _snack('Pesan dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus pesan'), error: true);
    }
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
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada pesan',
                  subtitle: 'Pesan masuk akan tampil di sini.',
                );
              }
              final filtered = _filterMessages(list);
              if (filtered.isEmpty) return _noResult('pesan');
              return Column(
                children: filtered
                    .take(50)
                    .map(
                      (m) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: FolioColors.primarySoft,
                          child: Text(
                            (m['sender_name']?.toString() ?? '?')
                                .substring(0, 1)
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(m['sender_name']?.toString() ?? '-'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['sender_email']?.toString() ?? ''),
                            Text(m['content']?.toString() ?? ''),
                            Text(
                              _fmtDate(m['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: FolioColors.muted,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (m['is_read'] != true)
                              IconButton(
                                tooltip: 'Tandai dibaca',
                                icon: const Icon(
                                  Icons.mark_email_read_outlined,
                                ),
                                onPressed: () =>
                                    _markRead((m['id'] as num).toInt()),
                              ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteMessage(m),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const ListSkeleton(rows: 5),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat pesan'),
              onRetry: () => ref.invalidate(adminMessagesProvider),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }

  /// Format `created_at` ISO -> `d/m/yyyy`. Fallback: 10 char pertama.
  String _fmtDate(dynamic raw) {
    if (raw == null) return '';
    final text = raw.toString();
    final dt = DateTime.tryParse(text);
    if (dt == null) {
      return text.length > 10 ? text.substring(0, 10) : text;
    }
    return '${dt.day}/${dt.month}/${dt.year}';
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
