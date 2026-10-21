import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/features/dashboard_me/dashboard_shell.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';
import 'package:frontend/features/dashboard_me/message_utils.dart';
import 'package:frontend/features/dashboard_me/project_media_utils.dart';
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

  List<SkillModel> _filterSkills(List<SkillModel> list) => _query.isEmpty
      ? list
      : list
          .where((s) => _hit([s.name, s.category]))
          .toList(growable: false);

  List<ExperienceModel> _filterExperiences(List<ExperienceModel> list) =>
      _query.isEmpty
          ? list
          : list
              .where((e) => _hit([e.role, e.company, e.location]))
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
      tab = 4;
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
    ref.invalidate(adminSkillsProvider);
    ref.invalidate(adminExperiencesProvider);
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
        const SidebarItem(
          icon: Icons.school_outlined,
          label: 'Skill & Pengalaman',
        ),
        SidebarItem(
          icon: Icons.mail_outline,
          label: 'Pesan Masuk',
          badge: messages.asData == null ? '…' : '$unread',
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
      onRefresh: () async => _refreshAll(),
      child: _body(
        totalUsers: userList.length,
        publicCount: publishedCount,
        totalProjects: projList.length,
        unread: unread,
        isLoading: isLoading,
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
    if (tab == 3) return _contentTab();
    if (tab == 4) return _messagesTab();
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
                  iconBg: AppColors.indigoSoft,
                  iconColor: AppColors.indigo,
                ),
                StatCard(
                  label: 'Portofolio publik',
                  value: _fmt(publicCount),
                  icon: Icons.open_in_new_rounded,
                  iconBg: AppColors.successSoft,
                  iconColor: AppColors.success,
                ),
                StatCard(
                  label: 'Total proyek',
                  value: _fmt(totalProjects),
                  icon: Icons.image_outlined,
                  iconBg: AppColors.warningSoft,
                  iconColor: Colors.orange,
                ),
                StatCard(
                  label: 'Pesan belum dibaca',
                  value: _fmt(unread),
                  icon: Icons.mail_outline,
                  iconBg: AppColors.indigoSoft,
                  iconColor: AppColors.indigo,
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
            AppColors.success,
          ),
          _barRow(
            'Proyek draft',
            draftProjects,
            projects.length,
            AppColors.muted,
          ),
          const SizedBox(height: 6),
          _barRow(
            'Portofolio publik',
            publishedUsers,
            users.length,
            AppColors.indigo,
          ),
          _barRow(
            'Portofolio draft',
            users.length - publishedUsers,
            users.length,
            AppColors.muted,
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
                  color: AppColors.muted,
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
              backgroundColor: AppColors.indigoSoft,
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
          badge = _pill('Terjangkau', AppColors.successSoft, AppColors.success);
          description = 'Backend merespons GET /health dengan status ok.';
        } else {
          badge = _pill(
            'Respons tidak dikenal',
            AppColors.warningSoft,
            Colors.orange.shade800,
          );
          description = 'Backend merespons, tetapi format tidak sesuai.';
        }
      case AsyncError():
        badge = _pill(
          'Tidak terjangkau',
          AppColors.dangerSoft,
          AppColors.danger,
        );
        description =
            'Tidak dapat menghubungi backend. Periksa koneksi atau server.';
      default:
        badge = _pill('Memeriksa…', AppColors.glassFill, AppColors.body);
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
              color: AppColors.indigoSoft,
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
                    color: AppColors.muted,
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
                        backgroundColor: AppColors.indigoSoft,
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.indigo,
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
    final payload = await showAdminUserDialog(
      context,
      uploadResume: ref.read(apiServiceProvider).adminUploadResume,
    );
    if (payload == null) return;
    try {
      await ref.read(apiServiceProvider).adminCreateUser(payload);
      ref.invalidate(adminUsersProvider);
      _snack('User dibuat');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal buat user'), error: true);
    }
  }

  Future<void> _editUser(UserModel u) async {
    final payload = await showAdminUserEditDialog(
      context,
      user: u,
      uploadAvatar: ref.read(apiServiceProvider).adminUploadAvatar,
    );
    if (payload == null) return;
    await _setUserField(u.id, payload);
    _snack('Avatar diperbarui');
  }

  Widget _userTableHeader() {
    const style = TextStyle(
      fontSize: 11,
      letterSpacing: 0.6,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    );
    return const Row(
      children: [
        Expanded(flex: 4, child: Text('NAMA', style: style)),
        Expanded(flex: 3, child: Text('MODERASI', style: style)),
        Expanded(flex: 2, child: Text('DRAFT / LIVE', style: style)),
        SizedBox(width: 52, child: Text('AKSI', style: style)),
      ],
    );
  }

  /// Baris tabel user. Kolom AKSI menonaktifkan akun (PATCH is_active),
  /// karena backend belum punya endpoint hapus user.
  Widget _userRow(UserModel u) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              ClipOval(
                child: AppNetworkImage(
                  url: u.avatarUrl,
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.fullName ?? u.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        if (u.isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.indigoSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'admin',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cyan,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(u.email, style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Switch.adaptive(
                value: u.isActive,
                activeThumbColor: AppColors.success,
                onChanged: (v) => _setUserField(u.id, {'is_active': v}),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  u.isActive ? 'Aktif' : 'Ditangguhkan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: u.isActive ? AppColors.body : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Switch.adaptive(
                value: u.isPublished,
                activeThumbColor: AppColors.success,
                onChanged: (v) => _setUserField(u.id, {'is_published': v}),
              ),
              const SizedBox(width: 6),
              Text(
                u.isPublished ? 'Live' : 'Draft',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: u.isPublished ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 52,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 18),
            color: const Color(0xFF171C28),
            onSelected: (v) {
              if (v == 'edit') {
                _editUser(u);
              }
              if (v == 'active') {
                _setUserField(u.id, {'is_active': !u.isActive});
              }
              if (v == 'role') {
                _setUserField(u.id, {'role': u.isAdmin ? 'user' : 'admin'});
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit avatar'),
              ),
              PopupMenuItem(
                value: 'active',
                child: Text(
                  u.isActive ? 'Nonaktifkan akun' : 'Aktifkan akun',
                ),
              ),
              PopupMenuItem(
                value: 'role',
                child: Text(u.isAdmin ? 'Jadikan user' : 'Jadikan admin'),
              ),
            ],
          ),
        ),
      ],
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _userTableHeader(),
                  const Divider(height: 20),
                  for (var i = 0; i < filtered.length; i++) ...[
                    _userRow(filtered[i]),
                    if (i < filtered.length - 1) const Divider(height: 20),
                  ],
                ],
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
    final payload = await showProjectDialog(
      context,
      uploadCover: ref.read(apiServiceProvider).adminUploadProjectCover,
    );
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
    final payload = await showProjectDialog(
      context,
      project: p,
      uploadCover: ref.read(apiServiceProvider).adminUploadProjectCover,
    );
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
    final api = ref.read(apiServiceProvider);
    await addProjectMediaFlow(
      context: context,
      project: p,
      add: (url, type, caption) => api.adminAddProjectMedia(
        p.id,
        mediaUrl: url,
        mediaType: type,
        caption: caption,
      ),
      onChanged: () {
        ref.invalidate(adminProjectsProvider);
        ref.invalidate(adminProjectsFilteredProvider);
      },
      notify: _snack,
      uploadMedia: api.adminUploadProjectMedia,
      successMessage: 'Media ditambahkan',
    );
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

  // ---------- Tab: Skill & Pengalaman ----------

  Future<void> _saveSkill({SkillModel? existing}) async {
    final payload = await showSkillDialog(
      context,
      skill: existing,
      // owner_id hanya relevan saat CREATE; PATCH tidak menerima field ini.
      ownerId: existing == null ? _ownerFilter : null,
    );
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.adminCreateSkill(payload);
        _snack('Skill dibuat');
      } else {
        await api.adminUpdateSkill(existing.id, payload);
        _snack('Skill diperbarui');
      }
      ref.invalidate(adminSkillsProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal simpan skill'), error: true);
    }
  }

  Future<void> _deleteSkill(SkillModel s) async {
    if (!await confirmDelete(context, 'Skill "${s.name}"')) return;
    try {
      await ref.read(apiServiceProvider).adminDeleteSkill(s.id);
      ref.invalidate(adminSkillsProvider);
      _snack('Skill dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus skill'), error: true);
    }
  }

  Future<void> _saveExperience({ExperienceModel? existing}) async {
    final payload = await showExperienceDialog(
      context,
      experience: existing,
      ownerId: existing == null ? _ownerFilter : null,
    );
    if (payload == null) return;
    try {
      final api = ref.read(apiServiceProvider);
      if (existing == null) {
        await api.adminCreateExperience(payload);
        _snack('Pengalaman dibuat');
      } else {
        await api.adminUpdateExperience(existing.id, payload);
        _snack('Pengalaman diperbarui');
      }
      ref.invalidate(adminExperiencesProvider);
    } catch (e) {
      _snack(friendlyError(e, 'Gagal simpan pengalaman'), error: true);
    }
  }

  Future<void> _deleteExperience(ExperienceModel e) async {
    if (!await confirmDelete(context, '"${e.role} @ ${e.company}"')) return;
    try {
      await ref.read(apiServiceProvider).adminDeleteExperience(e.id);
      ref.invalidate(adminExperiencesProvider);
      _snack('Pengalaman dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus pengalaman'), error: true);
    }
  }

  Widget _contentTab() {
    final users = ref.watch(adminUsersProvider).asData?.value ?? [];
    final skills = ref.watch(adminSkillsProvider(_ownerFilter));
    final exps = ref.watch(adminExperiencesProvider(_ownerFilter));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(
          eyebrow: 'Admin Console',
          title: 'Skill & Pengalaman',
          subtitle: 'Kelola keahlian dan riwayat kerja kreator.',
          actionLabel: 'Tambah skill',
          onAction: () => _saveSkill(),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Filter kreator',
          subtitle: 'Pilih kreator agar skill/pengalaman baru tercatat atas namanya.',
          child: DropdownButtonFormField<int?>(
            initialValue: _ownerFilter,
            decoration: const InputDecoration(
              labelText: 'Pemilik konten',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Semua kreator (konten baru milik saya)'),
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
          title: 'Skill',
          subtitle: 'Keahlian lintas kreator.',
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
                  subtitle: 'Skill kreator akan tampil di sini.',
                );
              }
              final filtered = _filterSkills(list);
              if (filtered.isEmpty) return _noResult('skill');
              return Column(
                children: filtered
                    .map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(s.name),
                        subtitle: Text(s.category ?? 'Other'),
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
              message: friendlyError(e, 'Gagal memuat skill'),
              onRetry: () => ref.invalidate(adminSkillsProvider),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Pengalaman',
          subtitle: 'Riwayat kerja lintas kreator.',
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
                  subtitle: 'Riwayat kerja kreator akan tampil di sini.',
                );
              }
              final filtered = _filterExperiences(list);
              if (filtered.isEmpty) return _noResult('pengalaman');
              return Column(
                children: filtered
                    .map(
                      (e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('${e.role} @ ${e.company}'),
                        subtitle: Text(e.location ?? '-'),
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
              message: friendlyError(e, 'Gagal memuat pengalaman'),
              onRetry: () => ref.invalidate(adminExperiencesProvider),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markRead(int? id) async {
    if (id == null) return; // id rusak: jangan crash, biarkan tetap unread
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
    final id = parseMessageId(m['id']);
    if (id == null) {
      _snack('Pesan tidak valid, gagal dihapus', error: true);
      return;
    }
    try {
      await ref.read(apiServiceProvider).adminDeleteMessage(id);
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
                          backgroundColor: AppColors.indigoSoft,
                          child:
                              Text(messageInitial(m['sender_name']?.toString())),
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
                                color: AppColors.muted,
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
                                    _markRead(parseMessageId(m['id'])),
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

  String _initials(String name) => initialsOf(name);

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
