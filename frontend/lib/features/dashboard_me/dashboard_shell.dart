import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/theme/app_theme.dart';

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
  });

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// Foto avatar di topbar: gambar full-bleed jika avatarUrl tersedia,
  /// fallback ke teks inisial saat URL kosong atau gagal dimuat.
  Widget _topbarAvatarImage({required Color destColor}) {
    final url = ApiConfig.resolveFileUrl(avatarUrl);
    if (url.isEmpty) {
      return Text(_initials,
          style: TextStyle(
              color: destColor,
              fontWeight: FontWeight.w800,
              fontSize: 12));
    }
    return Image.network(
      url,
      width: 32,
      height: 32,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Text(_initials,
          style: TextStyle(
              color: destColor,
              fontWeight: FontWeight.w800,
              fontSize: 12)),
    );
  }

  /// Token sidebar: beda antara mode terang & gelap.
  static _SidebarTokens _tokens(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const _SidebarTokens(
          bgTop: FolioDarkColors.sbBgTop,
          bgBottom: FolioDarkColors.sbBgBottom,
          text: FolioDarkColors.sbText,
          muted: FolioDarkColors.sbMuted,
          badge: FolioDarkColors.sbBadge,
          border: FolioDarkColors.sbBorder,
          title: FolioDarkColors.sbTitle,
          subtitle: FolioDarkColors.sbSubtitle,
          active: FolioDarkColors.primaryDeep,
        )
      : const _SidebarTokens(
          bgTop: FolioColors.sbBgTop,
          bgBottom: FolioColors.sbBgBottom,
          text: FolioColors.sbText,
          muted: FolioColors.sbMuted,
          badge: FolioColors.sbBadge,
          border: FolioColors.sbBorder,
          title: FolioColors.sbTitle,
          subtitle: FolioColors.sbSubtitle,
          active: FolioColors.primary,
        );

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
                    color: dark ? FolioDarkColors.ink : FolioColors.ink,
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
                    color: dark ? FolioDarkColors.muted : FolioColors.muted,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              dark ? FolioDarkColors.ink : FolioColors.ink,
                          side: BorderSide(
                            color: dark
                                ? FolioDarkColors.border
                                : FolioColors.border,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Batal',
                            style: TextStyle(fontWeight: FontWeight.w600)),
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
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(true),
                        child: const Text('Keluar',
                            style: TextStyle(fontWeight: FontWeight.w700)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout berhasil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      drawer: wide ? null : Drawer(child: _sidebar(context, ref, true)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) SizedBox(width: 272, child: _sidebar(context, ref, false)),
          Expanded(
            child: Column(
              children: [
                _topbar(context, wide),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebar(BuildContext context, WidgetRef ref, bool inDrawer) {
    final t = _tokens(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final danger = dark ? const Color(0xFFF97066) : const Color(0xFFB42318);
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
                        colors: [
                          FolioColors.primary,
                          Color(0xFF6D63F0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: FolioColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('F',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FolioSpace',
                            style: TextStyle(
                                color: t.title,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text('Portfolio builder',
                            style: TextStyle(
                                color: t.subtitle, fontSize: 12)),
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
              child: Text('MENU UTAMA',
                  style: TextStyle(
                      color: t.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 8),
            ...List.generate(menu.length, (i) {
              final m = menu[i];
              final active = i == selectedIndex;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (inDrawer) Navigator.pop(context);
                    onSelect(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: active
                          ? t.active
                          : Colors.transparent,
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
                        Icon(m.icon,
                            size: 20,
                            color: active
                                ? Colors.white
                                : t.text),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(m.label,
                              style: TextStyle(
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? Colors.white
                                      : t.text)),
                        ),
                        if (m.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : t.badge,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(m.badge!,
                                style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : t.text,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
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
                  Container(
                    height: 1,
                    color: t.border,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Logout',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: danger.withValues(alpha: 0.5)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      // Aksi destruktif: selalu merah, bukan hanya saat
                      // hover/tekan. Hover hanya memberi efek latar tipis.
                      foregroundColor: WidgetStateProperty.resolveWith(
                        (states) {
                          if (states.contains(WidgetState.disabled)) {
                            return t.muted;
                          }
                          return danger;
                        },
                      ),
                      overlayColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.hovered) ||
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

  Widget _topbar(BuildContext context, bool wide) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bar = dark ? FolioDarkColors.card : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: bar,
        border: Border(
          bottom: BorderSide(
            color: dark ? FolioDarkColors.border : FolioColors.border,
          ),
        ),
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
          _bellButton(context, bar),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: dark ? FolioDarkColors.border : FolioColors.border,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: dark
                      ? FolioDarkColors.primarySoft
                      : FolioColors.primarySoft,
                  // Avatar foto user jika ada (dukung path relatif hasil
                  // upload), fallback ke inisial saat kosong/gagal dimuat.
                  child: ClipOval(
                    child: _topbarAvatarImage(destColor: dark
                            ? FolioDarkColors.primary
                            : FolioColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 140),
                      child: Text(displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: dark
                                  ? FolioDarkColors.ink
                                  : FolioColors.ink)),
                    ),
                    Text(displayRole,
                        style: TextStyle(
                            color: dark
                                ? FolioDarkColors.muted
                                : FolioColors.muted,
                            fontSize: 11)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.keyboard_arrow_down,
                      size: 18,
                      color:
                          dark ? FolioDarkColors.muted : FolioColors.muted),
                  tooltip: 'Akun',
                  onSelected: (v) {
                    if (v == 'public') context.go('/');
                  },
                  // Logout sengaja hanya ada di sidebar agar tidak bingung
                  // dengan dua tombol logout.
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'public',
                        child: Row(children: [
                          Icon(Icons.public, size: 16),
                          SizedBox(width: 8),
                          Text('Lihat situs publik')
                        ])),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? FolioDarkColors.primary : FolioColors.primary;
    final soft = dark ? FolioDarkColors.primarySoft : FolioColors.primarySoft;
    final ink = dark ? FolioDarkColors.ink : FolioColors.ink;
    final muted = dark ? FolioDarkColors.muted : FolioColors.muted;
    return PopupMenuButton<Map<String, dynamic>?>(
      tooltip: 'Notifikasi',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: dark ? const Color(0xFF171C28) : Colors.white,
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
            child: Icon(
              Icons.notifications_outlined,
              size: 22,
              color: accent,
            ),
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
