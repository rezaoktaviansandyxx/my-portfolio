import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final String? badge;
  const SidebarItem({required this.icon, required this.label, this.badge});
}

/// Shell dashboard (user & admin). Sidebar memakai latar gelap dengan
/// aksen indigo agar logo + item aktif terlihat tegas; topbar & konten
/// mengikuti tema (terang/gelap).
class DashboardShell extends ConsumerWidget {
  final int selectedIndex;
  final List<SidebarItem> menu;
  final ValueChanged<int> onSelect;
  final String displayName;
  final String displayRole;
  final String? avatarUrl;
  final int unreadCount;
  final Widget child;
  final String searchHint;

  /// Search bar: controller & callback milik parent (dashboard) agar hasil
  /// ketikan bisa memfilter daftar di tab yang aktif.
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearch;

  /// Lonceng notifikasi: daftar pesan belum dibaca (data asli dari provider)
  /// + aksi saat item / footer menu diklik (biasanya lompat ke tab Pesan).
  final List<Map<String, dynamic>> unreadMessages;
  final ValueChanged<Map<String, dynamic>>? onOpenNotification;
  final VoidCallback? onOpenInbox;

  /// Bila diisi, pull-to-refresh di body dashboard memicu callback ini.
  /// RefreshIndicator dipasang di shell agar gestur tak pernah mati —
  /// dulu tiap halaman membungkus body non-scrollable sehingga pull
  /// selalu sia-sia (audit Medium).
  final Future<void> Function()? onRefresh;

  const DashboardShell({
    super.key,
    required this.selectedIndex,
    required this.menu,
    required this.onSelect,
    required this.displayName,
    required this.displayRole,
    this.avatarUrl,
    required this.unreadCount,
    required this.child,
    this.searchHint = 'Cari proyek, pengguna...',
    this.searchController,
    this.onSearch,
    this.unreadMessages = const [],
    this.onOpenNotification,
    this.onOpenInbox,
    this.onRefresh,
  });

  String get _initials => initialsOf(displayName, fallback: 'U');

  /// Foto avatar di topbar: gambar full-bleed jika avatarUrl tersedia,
  /// fallback ke teks inisial saat URL kosong atau gagal dimuat.
  Widget _topbarAvatarImage({required Color destColor}) {
    final url = ApiConfig.resolveFileUrl(avatarUrl);
    if (url.isEmpty) {
      return Text(
        _initials,
        style: TextStyle(
          color: destColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        // Inisial sebagai lapisan dasar: AppNetworkImage menimpanya dengan
        // foto, dan fallback-nya tampak transparan sehingga inisial tetap
        // terlihat saat foto gagal dimuat.
        Text(
          _initials,
          style: TextStyle(
            color: destColor,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        AppNetworkImage(url: avatarUrl, width: 32, height: 32),
      ],
    );
  }

  /// Token sidebar: beda antara mode terang & gelap.
  static _SidebarTokens _tokens(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const _SidebarTokens(
          bgTop: AppColors.bgAlt,
          bgBottom: AppColors.bg,
          text: AppColors.body,
          muted: AppColors.muted,
          badge: AppColors.indigoSoft,
          border: AppColors.glassBorder,
          title: AppColors.ink,
          subtitle: AppColors.muted,
          active: AppColors.indigo,
        )
      : const _SidebarTokens(
          bgTop: AppColors.bgAlt,
          bgBottom: AppColors.bg,
          text: AppColors.body,
          muted: AppColors.muted,
          badge: AppColors.indigoSoft,
          border: AppColors.glassBorder,
          title: AppColors.ink,
          subtitle: AppColors.muted,
          active: AppColors.indigo,
        );

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB42318).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFB42318),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Keluar dari akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu akan keluar dari dashboard dan perlu login ulang '
                  'untuk mengaksesnya.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.ink,
                          side: BorderSide(color: AppColors.glassBorder),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB42318),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      await _doLogout(context, ref);
    }
  }

  Future<void> _doLogout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authNotifierProvider.notifier).logout();
    } finally {
      if (context.mounted) {
        context.go('/login');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logout berhasil')));
      }
    }
  }

  /// Pull-to-refresh hanya dipasang bila onRefresh diisi. AlwaysScrollable
  /// menjamin gestur pull tetap terdeteksi walau konten lebih pendek dari
  /// viewport (physics default tidak overscroll).
  Widget _refreshableChild() {
    return LayoutBuilder(
      builder: (context, viewport) {
        final core = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            // RefreshIndicator menaruh child-nya di Stack dengan loose
            // constraint: konten pendek shrink-wrap → tak pernah overscroll
            // → pull mati. minHeight mengisi viewport agar pull selalu bisa.
            constraints: BoxConstraints(minHeight: viewport.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: child,
              ),
            ),
          ),
        );
        final refresh = onRefresh;
        if (refresh == null) return core;
        return RefreshIndicator(onRefresh: refresh, child: core);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width > kDesktopBreakpoint;
    return Scaffold(
      drawer: wide ? null : Drawer(child: _sidebar(context, ref, true)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            _DashboardRail(
              selectedIndex: selectedIndex,
              menu: menu,
              onSelect: onSelect,
              onLogout: () => _confirmLogout(context, ref),
            ),
          Expanded(
            child: Column(
              children: [
                _topbar(context, ref, wide),
                Expanded(child: _refreshableChild()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar kustom dipertahankan khusus untuk Drawer mobile (Task 8):
  // di desktop dipakai _DashboardRail, dan `wide ? null : Drawer(...)` di
  // build() di atas adalah satu-satunya pemakai _sidebar/_SidebarTokens.
  Widget _sidebar(BuildContext context, WidgetRef ref, bool inDrawer) {
    final t = _tokens(context);
    final danger = const Color(0xFFF97066);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.bgTop, t.bgBottom],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.indigo, Color(0xFF6D63F0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.indigo.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'F',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FolioSpace',
                          style: TextStyle(
                            color: t.title,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Portfolio builder',
                          style: TextStyle(color: t.subtitle, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (inDrawer)
                    IconButton(
                      icon: Icon(Icons.close, color: t.muted, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'MENU UTAMA',
                style: TextStyle(
                  color: t.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(menu.length, (i) {
              final m = menu[i];
              final active = i == selectedIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (inDrawer) Navigator.pop(context);
                    onSelect(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: active ? t.active : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: t.active.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          m.icon,
                          size: 20,
                          color: active ? Colors.white : t.text,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            m.label,
                            style: TextStyle(
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active ? Colors.white : t.text,
                            ),
                          ),
                        ),
                        if (m.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : t.badge,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              m.badge!,
                              style: TextStyle(
                                color: active ? Colors.white : t.text,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(height: 1, color: t.border),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: danger.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          // Aksi destruktif: selalu merah, bukan hanya saat
                          // hover/tekan. Hover hanya memberi efek latar tipis.
                          foregroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.disabled)) {
                              return t.muted;
                            }
                            return danger;
                          }),
                          overlayColor: WidgetStateProperty.resolveWith(
                            (states) =>
                                states.contains(WidgetState.hovered) ||
                                    states.contains(WidgetState.pressed)
                                ? danger.withValues(alpha: 0.08)
                                : Colors.transparent,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pil status publish di topbar: hijau Live, kuning Draft.
  Widget _statusPill(WidgetRef ref) {
    final user = ref.watch(myProfileProvider).value;
    final published = user?.isPublished ?? false;
    final color = published ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            published ? 'Live' : 'Draft',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _topbar(BuildContext context, WidgetRef ref, bool wide) {
    final bar = AppColors.glassFill;
    return Container(
      decoration: BoxDecoration(
        color: bar,
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (!wide)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                suffixIcon: (searchController?.text.isNotEmpty ?? false)
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          searchController?.clear();
                          // Reset state filter di parent juga.
                          onSearch?.call('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Spacer(),
          _statusPill(ref),
          const SizedBox(width: 12),
          _bellButton(context, bar),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.indigoSoft,
                  // Avatar foto user jika ada (dukung path relatif hasil
                  // upload), fallback ke inisial saat kosong/gagal dimuat.
                  child: ClipOval(
                    child: _topbarAvatarImage(destColor: AppColors.indigo),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Text(
                      displayRole,
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  tooltip: 'Akun',
                  onSelected: (v) {
                    if (v == 'public') context.go('/');
                  },
                  // Logout sengaja hanya ada di sidebar agar tidak bingung
                  // dengan dua tombol logout.
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'public',
                      child: Row(
                        children: [
                          Icon(Icons.public, size: 16),
                          SizedBox(width: 8),
                          Text('Lihat situs publik'),
                        ],
                      ),
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

  /// Lonceng notifikasi: dibungkus PopupMenuButton agar klik memunculkan
  /// daftar pesan belum dibaca. Item -> lompat ke tab Pesan; footer membuka
  /// semua pesan. Titik merah tetap mengikuti `unreadCount`.
  Widget _bellButton(BuildContext context, Color bar) {
    final accent = AppColors.indigo;
    final soft = AppColors.indigoSoft;
    final ink = AppColors.ink;
    final muted = AppColors.muted;
    return PopupMenuButton<Map<String, dynamic>?>(
      tooltip: 'Notifikasi',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: const Color(0xFF171C28),
      onSelected: (m) {
        // NOTE: onSelected TIDAK terpanggil bila value PopupMenuItem null
        // (Flutter menganggap null = popup ditutup tanpa memilih). Karena itu
        // footer "Lihat semua pesan" memakai sentinel `_view: 'all'`, bukan null.
        if (m == null) return;
        if (m['_view'] == 'all') {
          onOpenInbox?.call();
        } else {
          onOpenNotification?.call(m);
        }
      },
      itemBuilder: (_) {
        final items = <PopupMenuEntry<Map<String, dynamic>?>>[];
        if (unreadMessages.isEmpty) {
          items.add(
            const PopupMenuItem<Map<String, dynamic>?>(
              enabled: false,
              child: Row(
                children: [
                  Icon(Icons.notifications_none_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Tidak ada notifikasi baru'),
                ],
              ),
            ),
          );
        } else {
          items.add(
            PopupMenuItem<Map<String, dynamic>?>(
              enabled: false,
              child: Text(
                '${unreadMessages.length} pesan belum dibaca',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: muted,
                ),
              ),
            ),
          );
          for (final m in unreadMessages.take(5)) {
            final sender = m['sender_name']?.toString() ?? 'Anonim';
            final content = m['content']?.toString() ?? '';
            final raw = m['created_at']?.toString() ?? '';
            final date = raw.length > 10 ? raw.substring(0, 10) : raw;
            items.add(
              PopupMenuItem<Map<String, dynamic>?>(
                value: m,
                child: Row(
                  children: [
                    Icon(
                      Icons.mark_email_unread_outlined,
                      size: 18,
                      color: accent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sender,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: ink,
                                  ),
                                ),
                              ),
                              Text(
                                date,
                                style: TextStyle(fontSize: 11, color: muted),
                              ),
                            ],
                          ),
                          Text(
                            content.isEmpty ? '(tanpa isi)' : content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (unreadMessages.length > 5) {
            items.add(
              PopupMenuItem<Map<String, dynamic>?>(
                enabled: false,
                child: Text(
                  '+${unreadMessages.length - 5} pesan lainnya',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ),
            );
          }
        }
        items.add(const PopupMenuDivider());
        items.add(
          PopupMenuItem<Map<String, dynamic>?>(
            // Sentinel! Jangan pakai null: onSelected tidak terpanggil untuk
            // value null (padding popup), sehingga tombolnya "tidak ke mana-mana".
            value: const {'_view': 'all'},
            height: 42,
            child: Row(
              children: [
                Icon(Icons.mail_outline, size: 16, color: accent),
                const SizedBox(width: 10),
                Text(
                  'Lihat semua pesan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        );
        return items;
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: soft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.notifications_outlined, size: 22, color: accent),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 5,
              top: 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5484D),
                  shape: BoxShape.circle,
                  border: Border.all(color: bar, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Rail navigasi kiri yang bisa diciutkan. Stateful hanya untuk `extended`.
class _DashboardRail extends StatefulWidget {
  final int selectedIndex;
  final List<SidebarItem> menu;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  const _DashboardRail({
    required this.selectedIndex,
    required this.menu,
    required this.onSelect,
    required this.onLogout,
  });

  @override
  State<_DashboardRail> createState() => _DashboardRailState();
}

class _DashboardRailState extends State<_DashboardRail> {
  bool _extended = true;

  /// Lebar rail saat label penuh; sama dengan minExtendedWidth NavigationRail.
  /// Dipakai juga untuk lebar tombol logout supaya keduanya sejajar.
  static const _extendedWidth = 210.0;
  static const _gutter = 12.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgAlt,
        border: Border(right: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        child: NavigationRail(
          extended: _extended,
          minExtendedWidth: _extendedWidth,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.indigo.withValues(alpha: 0.28),
          selectedIconTheme: const IconThemeData(color: AppColors.ink),
          unselectedIconTheme: const IconThemeData(color: AppColors.muted),
          selectedLabelTextStyle: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
          unselectedLabelTextStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 12.5,
          ),
          groupAlignment: -0.85,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: IconButton(
              onPressed: () => setState(() => _extended = !_extended),
              icon: Icon(
                _extended
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
              ),
              color: AppColors.muted,
              tooltip: _extended ? 'Ciutkan' : 'Lebarkan',
            ),
          ),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _extended ? _gutter : 0,
                  0,
                  _extended ? _gutter : 0,
                  16,
                ),
                // Rail expanded memakai tombol penuh (ikon + teks "Logout")
                // agar aksinya terbaca, bukan cuma simbol. Saat rail dicabut
                // ruangnya sempit, ikon tetap jadi tombol dengan label kecil
                // di bawahnya supaya makna "keluar" tidak hilang.
                child: _LogoutButton(
                  onPressed: widget.onLogout,
                  extended: _extended,
                  // Tombol tidak otomatis melar; lebarkan sesuai lebar rail
                  // supaya rata dengan item menu di atasnya.
                  width: _extended ? _extendedWidth - _gutter * 2 : null,
                ),
              ),
            ),
          ),
          selectedIndex: widget.selectedIndex,
          onDestinationSelected: widget.onSelect,
          destinations: [
            for (final item in widget.menu)
              NavigationRailDestination(
                icon: Badge(
                  isLabelVisible: item.badge != null,
                  label: Text(item.badge ?? ''),
                  backgroundColor: AppColors.danger,
                  child: Icon(item.icon),
                ),
                label: Text(item.label),
              ),
          ],
        ),
      ),
    );
  }
}

/// Tombol keluar di rail desktop: expanded → ikon + teks "Logout" dalam
/// outline merah, collapsed → ikon dengan label "Logout" kecil di bawahnya.
/// Mengganti IconButton telanjang supaya aksi destruktif selalu terbaca teks.
class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool extended;

  /// Lebar eksplisit saat rail extended; null → shrink-wrap (rail tercabut).
  final double? width;

  const _LogoutButton({
    required this.onPressed,
    required this.extended,
    required this.width,
  });

  static const _danger = Color(0xFFF97066);

  @override
  Widget build(BuildContext context) {
    if (!extended) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.logout_rounded),
            color: _danger,
            tooltip: 'Keluar',
          ),
          const SizedBox(height: 2),
          Text(
            'Logout',
            style: const TextStyle(
              color: _danger,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text(
        'Logout',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      style:
          OutlinedButton.styleFrom(
            side: BorderSide(color: _danger.withValues(alpha: 0.5)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ).copyWith(
            // Aksi destruktif: merah terus-menerus, bukan hanya saat hover/tekan.
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? AppColors.muted
                  : _danger,
            ),
            overlayColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.pressed)
                  ? _danger.withValues(alpha: 0.08)
                  : Colors.transparent,
            ),
          ),
    );
    final w = width;
    return w == null ? button : SizedBox(width: w, child: button);
  }
}

/// Token _sidebar di atas: hanya dipakai Drawer mobile (desktop memakai
/// _DashboardRail; dipertahankan per Task 8, lihat komentar di _sidebar).
class _SidebarTokens {
  final Color bgTop;
  final Color bgBottom;
  final Color text;
  final Color muted;
  final Color badge;
  final Color border;
  final Color title;
  final Color subtitle;
  final Color active;
  const _SidebarTokens({
    required this.bgTop,
    required this.bgBottom,
    required this.text,
    required this.muted,
    required this.badge,
    required this.border,
    required this.title,
    required this.subtitle,
    required this.active,
  });
}
