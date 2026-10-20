import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/features/dashboard_me/dashboard_shell.dart';
import 'package:frontend/features/dashboard_me/dashboard_dialogs.dart';
import 'package:frontend/features/dashboard_me/project_media_utils.dart';
import 'package:frontend/features/dashboard_me/project_order.dart';
import 'package:frontend/features/dashboard_me/project_reorder_card.dart';
import 'package:frontend/shared/widgets/errors.dart';
import 'package:frontend/shared/widgets/folio_field.dart';
import 'package:frontend/shared/widgets/folio_widgets.dart';
import 'package:frontend/shared/widgets/skeleton.dart';
import 'package:frontend/shared/widgets/upload_field.dart';

/// Ubah status publish situs. Dipakai kartu profil dan form profil.
Future<void> setSitePublished(WidgetRef ref, bool published) async {
  await ref.read(apiServiceProvider).setPublish(!published);
  ref.invalidate(myProfileProvider);
}

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  int tab = 0;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  /// Urutan lokal proyek untuk drag-and-drop; diisi sekali dari provider lalu
  /// di-update optimistis saat kartu digeser.
  List<ProjectModel> _localOrder = [];
  bool _orderSeeded = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Tulis ulang `display_order` sesuai urutan baru. Optimistis: UI sudah
  /// di-update sebelum PATCH; kalau gagal, provider di-refresh agar kembali
  /// ke urutan server.
  Future<void> _persistOrder(List<ProjectModel> ordered) async {
    final api = ref.read(apiServiceProvider);
    try {
      for (var i = 0; i < ordered.length; i++) {
        if (ordered[i].displayOrder == i) continue;
        await api.updateMyProject(ordered[i].id, {'display_order': i});
      }
    } catch (e) {
      _snack('Gagal menyimpan urutan: $e', error: true);
    } finally {
      ref.invalidate(myProjectsProvider);
    }
  }

  void _moveProject(int from, int to) {
    if (from == to || from < 0 || to < 0) return;
    if (from >= _localOrder.length) return;
    final list = List<ProjectModel>.from(_localOrder);
    final moved = list.removeAt(from);
    list.insert(to.clamp(0, list.length), moved);
    setState(() => _localOrder = list);
    _persistOrder(list);
  }

  /// Filter sederhana untuk search bar di topbar (case-insensitive).
  bool _hit(List<String?> fields) =>
      _query.isEmpty ||
      fields.any((f) => f?.toLowerCase().contains(_query) ?? false);

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

  /// Lompat ke tab Pesan dari lonceng notifikasi; bersihkan query agar
  /// pesan yang baru dibuka tidak tersaring.
  void _goInbox() {
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

  Future<void> _togglePublish(bool published) async {
    try {
      await setSitePublished(ref, published);
      _snack(published ? 'Situs di-unpublish' : 'Situs dipublish');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal ubah status publish'), error: true);
    }
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

  /// Format `created_at` ISO backend -> `d/m/yyyy`. Fallback: 10 char pertama.
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
    final first = firstWordOf(name);
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
      displayRole: profile.asData?.value.headline ?? '',
      avatarUrl: profile.asData?.value.avatarUrl,
      unreadCount: unread,
      searchController: _search,
      onSearch: (q) => setState(() => _query = q.trim().toLowerCase()),
      unreadMessages:
          msgList.where((m) => m['is_read'] != true).toList(),
      onOpenNotification: (_) => _goInbox(),
      onOpenInbox: _goInbox,
      onRefresh: () async => _refreshAll(),
      child: _body(first),
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
            final initials = initialsOf(name);
            final avatarUrl = ApiConfig.resolveFileUrl(u.avatarUrl);
            return Row(
              children: [
                // Avatar foto user jika tersedia, fallback ke inisial
                // saat kosong atau gagal dimuat.
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.indigoSoft,
                  child: ClipOval(
                    child: avatarUrl.isEmpty
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.indigo,
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              // Inisial sebagai lapisan dasar: AppNetworkImage
                              // menimpanya dengan foto, dan fallback-nya tampak
                              // transparan sehingga inisial tetap terlihat saat
                              // foto gagal dimuat.
                              Text(
                                initials,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.indigo,
                                ),
                              ),
                              AppNetworkImage(
                                url: u.avatarUrl,
                                width: 60,
                                height: 60,
                              ),
                            ],
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
                      if ((u.headline ?? '').isNotEmpty)
                        Text(
                          u.headline!,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      Text(
                        'foliospace.id/${u.profileSlug ?? u.username.toLowerCase()}',
                        style: const TextStyle(
                          color: AppColors.indigo,
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
                      onPressed: u.profileSlug == null
                          ? null
                          : () => context.go('/u/${u.profileSlug}'),
                      child: const Text('Preview'),
                    ),
                    ElevatedButton(
                      onPressed: () => _togglePublish(u.isPublished),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: u.isPublished
                            ? Colors.transparent
                            : AppColors.indigo,
                        foregroundColor: u.isPublished
                            ? AppColors.warning
                            : Colors.white,
                        side: u.isPublished
                            ? const BorderSide(
                                color: AppColors.warning,
                                width: 1.2,
                              )
                            : null,
                        elevation: 0,
                      ),
                      child: Text(u.isPublished ? 'Unpublish' : 'Buka situs'),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const ProfileCardSkeleton(),
          error: (e, _) => Text(friendlyError(e, 'Gagal memuat profil')),
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
          final filtered = _filterProjects(list);
          if (filtered.isEmpty) return _noResult('proyek');
          return Column(
            children: filtered.take(3).map((p) {
              final cat = (p.skills?.isNotEmpty == true)
                  ? p.skills!.first.name
                  : (p.status ?? 'Proyek');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.glassBorder),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.indigoSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.indigo,
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
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.status ?? 'Aktif',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
              );
            }).toList(),
          );
        },
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorCard(
          message: friendlyError(e, 'Gagal memuat proyek'),
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
        Text(l, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    ),
  );

  Widget _vdiv() => Container(width: 1, height: 36, color: AppColors.glassBorder);

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
              backgroundColor: AppColors.indigoSoft,
              valueColor: const AlwaysStoppedAnimation(AppColors.indigo),
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
          color: done ? AppColors.success : AppColors.muted,
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
    final ini = initialsOf(name);
    final preview = full
        ? content
        : (content.length > 42 ? '${content.substring(0, 42)}...' : content);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.indigoSoft,
            child: Text(
              ini,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: AppColors.indigo,
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
                  color: AppColors.indigo,
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
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.indigoSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          messages.isLoading
              ? '…'
              : '${_unreadCount(messages.asData?.value ?? const [])} belum dibaca',
          style: const TextStyle(
            color: AppColors.indigo,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
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
          final filtered = _filterMessages(list);
          if (filtered.isEmpty) return _noResult('pesan');
          return Column(
            children:
                filtered.take(3).map((m) => _messageTile(m)).toList(),
          );
        },
        loading: () => const ListSkeleton(rows: 3),
        error: (e, _) => ErrorCard(
          message: friendlyError(e, 'Gagal memuat pesan'),
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
            final slug = profile.asData?.value.profileSlug;
            if (slug == null || slug.isEmpty) {
              _snack(
                'Simpan Profile slug dulu di bawah untuk membuka situs publik.',
                error: true,
              );
              return;
            }
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
            message: friendlyError(e, 'Gagal memuat profil'),
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
      uploadCover: ref.read(apiServiceProvider).uploadMyCover,
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
      _snack(friendlyError(e, 'Gagal simpan proyek'), error: true);
    }
  }

  Future<void> _deleteProject(ProjectModel p) async {
    if (!await confirmDelete(context, 'Proyek "${p.title}"')) return;
    try {
      await ref.read(apiServiceProvider).deleteMyProject(p.id);
      ref.invalidate(myProjectsProvider);
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
      add: (url, type, caption) => api.addMyProjectMedia(
        p.id,
        mediaUrl: url,
        mediaType: type,
        caption: caption,
      ),
      onChanged: () => ref.invalidate(myProjectsProvider),
      notify: _snack,
      uploadMedia: api.uploadMyMedia,
    );
  }

  /// Grid drag-and-drop: kartu bisa digeser ke dropzone mana pun.
  /// Index `i` kartu = posisi target; dropzone terakhir menaruh di ujung.
  Widget _reorderGrid(List<ProjectModel> items) {
    final reorderable = _query.isEmpty;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (var i = 0; i < items.length; i++)
          if (reorderable)
            DragTarget<int>(
              onAcceptWithDetails: (d) => _moveProject(d.data, i),
              builder: (_, candidate, __) => Draggable<int>(
                data: i,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(width: 300, child: _projectCard(items[i], i)),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _projectCard(items[i], i),
                ),
                child: _projectCard(items[i], i, highlighted: candidate.isNotEmpty),
              ),
            )
          else
            _projectCard(items[i], i),
        if (reorderable) _dropzone(items.length),
      ],
    );
  }

  Widget _dropzone(int index) {
    return DragTarget<int>(
      onAcceptWithDetails: (d) => _moveProject(d.data, index),
      builder: (_, candidate, __) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 240,
          height: 132,
          decoration: BoxDecoration(
            color: active
                ? AppColors.cyan.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.cyan : AppColors.glassBorder,
              width: 1.4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.file_upload_outlined,
                  size: 22,
                  color: active ? AppColors.cyan : AppColors.muted,
                ),
                const SizedBox(height: 6),
                Text(
                  'Zona drop',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: active ? AppColors.cyan : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _projectCard(ProjectModel p, int index, {bool highlighted = false}) {
    // Body kartu diekstrak ke ProjectReorderCard agar bisa dijaga test
    // widget: kartu ini hidup langsung di dalam Wrap dengan tinggi tak
    // terbatas, jadi tingginya harus tetap dibatasi (lihat C1).
    return ProjectReorderCard(
      project: p,
      index: index,
      highlighted: highlighted,
      onEdit: () => _saveProject(existing: p),
      onMedia: () => _addProjectMedia(p),
      onDelete: () => _deleteProject(p),
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
          onAction: () => _saveProject(),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Daftar proyek',
          subtitle: 'Edit, tambah media, atau hapus lewat menu ⋮ tiap proyek.',
          child: projects.when(
            data: (list) {
              if (list.isEmpty) {
                return const EmptyCard(
                  title: 'Belum ada proyek',
                  subtitle: 'Proyek akan tampil di sini.',
                );
              }
              final filtered = _filterProjects(list);
              if (filtered.isEmpty) return _noResult('proyek');
              // Gabung data terbaru dengan urutan custom: konten hasil edit()
              // tampil segar, urutan drag tetap terjaga bila id tidak berubah.
              _localOrder = mergeProjectOrder(
                _orderSeeded ? _localOrder : const [],
                list,
              );
              _orderSeeded = true;
              return _reorderGrid(
                _query.isEmpty ? _localOrder : filtered,
              );
            },
            loading: () => const ListSkeleton(rows: 3),
            error: (e, _) => ErrorCard(
              message: friendlyError(e, 'Gagal memuat proyek'),
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
      _snack(friendlyError(e, 'Gagal simpan skill'), error: true);
    }
  }

  Future<void> _deleteSkill(SkillModel s) async {
    if (!await confirmDelete(context, 'Skill "${s.name}"')) return;
    try {
      await ref.read(apiServiceProvider).deleteMySkill(s.id);
      ref.invalidate(mySkillsProvider);
      _snack('Skill dihapus');
    } catch (e) {
      _snack(friendlyError(e, 'Gagal hapus skill'), error: true);
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
      _snack(friendlyError(e, 'Gagal simpan pengalaman'), error: true);
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
      _snack(friendlyError(err, 'Gagal hapus pengalaman'), error: true);
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
          subtitle: 'Ketuk ikon pensil untuk mengedit skill.',
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
              message: friendlyError(e, 'Gagal memuat skill'),
              onRetry: () => ref.invalidate(mySkillsProvider),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          title: 'Pengalaman kerja',
          subtitle: 'Role, perusahaan, dan periode kerja.',
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
              message: friendlyError(e, 'Gagal memuat pengalaman'),
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
      _snack(friendlyError(e, 'Gagal tandai pesan'), error: true);
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
      _snack(friendlyError(e, 'Gagal hapus pesan'), error: true);
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
          final filtered = _filterMessages(list);
          if (filtered.isEmpty) return _noResult('pesan');
          return Column(
            children: filtered
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
          message: friendlyError(e, 'Gagal memuat pesan'),
          onRetry: () => ref.invalidate(myMessagesProvider),
        ),
      ),
    );
  }
}

/// Form profil: full_name/headline/bio/profile_slug/avatar_url/resume_url
/// + toggle publish + ganti password. Avatar bisa di-upload langsung lewat
/// `UploadField` (`uploadMyAvatar`); resume masih via URL karena BE belum
/// punya `POST /me/upload/resume` (hanya `/admin/upload/resume`).
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
    _slug.addListener(() => setState(() {}));
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
      widget.onError(friendlyError(e, 'Gagal simpan profil'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePublish(bool published) async {
    try {
      await setSitePublished(ref, published);
      widget.onSaved();
      widget.onSuccess(published ? 'Situs di-unpublish' : 'Situs dipublish');
    } catch (e) {
      widget.onError(friendlyError(e, 'Gagal ubah status publish'));
    }
  }

  Future<void> _changePassword() async {
    final pair = await showChangePasswordDialog(context);
    if (pair == null) return;
    try {
      await ref.read(authServiceProvider).changePassword(pair[0], pair[1]);
      widget.onSuccess('Password diganti');
    } catch (e) {
      widget.onError(friendlyError(e, 'Gagal ganti password'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final published = widget.user.isPublished;
    final slug = _slug.text.trim();
    return SectionCard(
      title: 'Edit profil',
      subtitle: slug.isEmpty
          ? 'Lengkapi identitasmu, lalu atur slug & publikasi.'
          : 'Publik di foliospace.id/$slug',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- Identitas ----------
          const FormHeading('Identitas'),
          folioField(
            _fullName,
            'Nama lengkap',
            hint: 'misal: Budi Santoso',
            icon: Icons.badge_outlined,
          ),
          folioField(
            _headline,
            'Headline',
            hint: 'misal: Product Designer',
            icon: Icons.work_outline,
          ),
          folioField(
            _bio,
            'Bio',
            hint: 'Ceritakan dirimu...',
            maxLines: 3,
            icon: Icons.notes_rounded,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),

          // ---------- Alamat publik ----------
          const FormHeading('Alamat publik'),
          folioField(
            _slug,
            'Profile slug',
            hint: 'huruf-kecil-angka-strip',
            icon: Icons.alternate_email_rounded,
            prefixText: 'foliospace.id/',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 4),

          // ---------- Media ----------
          const FormHeading('Media'),
          UploadField(
            controller: _avatar,
            label: 'Avatar URL',
            hint: 'https://... atau klik ikon upload',
            icon: Icons.image_outlined,
            upload: ref.read(apiServiceProvider).uploadMyAvatar,
          ),
          folioField(
            _resume,
            'Resume URL',
            hint: 'https://... (hasil upload resume)',
            keyboard: TextInputType.url,
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 12),

          // ---------- Publish ----------
          _publishCard(context, published: published),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SkeletonBox(width: 16, height: 16, radius: 8) : const Icon(Icons.save_outlined, size: 18),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan profil'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _changePassword,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Ganti password'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kartu status publikasi: ikon bola dunia + label status + Switch,
  /// menggantikan SwitchListTile polos agar terlihat menyatu.
  Widget _publishCard(
    BuildContext context, {
    required bool published,
  }) {
    final bg = published
        ? (AppColors.successSoft)
        : (AppColors.bg);
    final border = published
        ? ((AppColors.success)
              .withValues(alpha: 0.35))
        : (AppColors.glassBorder);
    final iconBg =
        AppColors.indigoSoft;
    final iconColor =
        published
            ? (AppColors.success)
            : (AppColors.indigo);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              published ? Icons.public_rounded : Icons.edit_off_outlined,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publish situs',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  published
                      ? 'Situsmu bisa diakses publik lewat slug di atas.'
                      : 'Situs masih privat — aktifkan untuk menerbitkan.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color:
                        AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: published, onChanged: (_) => _togglePublish(published)),
        ],
      ),
    );
  }
}

