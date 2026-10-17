import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/theme/app_theme.dart';

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
  final int unreadCount;
  final Widget child;
  final String searchHint;

  const DashboardShell({
    super.key,
    required this.selectedIndex,
    required this.menu,
    required this.onSelect,
    required this.displayName,
    required this.displayRole,
    required this.unreadCount,
    required this.child,
    this.searchHint = 'Cari proyek, pengguna...',
  });

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
          active: FolioDarkColors.primaryDeep,
        )
      : const _SidebarTokens(
          bgTop: FolioColors.sbBgTop,
          bgBottom: FolioColors.sbBgBottom,
          text: FolioColors.sbText,
          muted: FolioColors.sbMuted,
          badge: FolioColors.sbBadge,
          border: FolioColors.sbBorder,
          active: FolioColors.primary,
        );

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Kamu akan keluar dari dashboard dan perlu login ulang untuk mengaksesnya. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ya, logout'),
          ),
        ],
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
                _topbar(context, ref, wide),
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FolioSpace',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text('Portfolio builder',
                            style: TextStyle(
                                color: Color(0xFF9BA2BA), fontSize: 12)),
                      ],
                    ),
                  ),
                  if (inDrawer)
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFF9BA2BA), size: 20),
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
                    icon: Icon(Icons.logout_rounded,
                        size: 18, color: t.text),
                    label: Text('Logout',
                        style:
                            TextStyle(color: t.text, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.border),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    // Warna teks diatur lewat style TextStyle di atas agar
                    // tidak menimpa warna dimatikan/disabled bawaan.
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topbar(BuildContext context, WidgetRef ref, bool wide) {
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
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                tooltip: 'Notifikasi',
                icon: Icon(
                  Icons.notifications_outlined,
                  color: dark ? FolioDarkColors.primary : FolioColors.primary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      dark ? FolioDarkColors.primarySoft : FolioColors.primarySoft,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
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
                  child: Text(_initials,
                      style: TextStyle(
                          color: dark
                              ? FolioDarkColors.primary
                              : FolioColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
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
                    if (v == 'logout') _confirmLogout(context, ref);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'public',
                        child: Row(children: [
                          Icon(Icons.public, size: 16),
                          SizedBox(width: 8),
                          Text('Lihat situs publik')
                        ])),
                    PopupMenuItem(
                        value: 'logout',
                        child: Row(children: [
                          Icon(Icons.logout,
                              size: 16, color: Color(0xFFB42318)),
                          SizedBox(width: 8),
                          Text('Logout',
                              style: TextStyle(
                                  color: Color(0xFFB42318)))
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
}

class _SidebarTokens {
  final Color bgTop;
  final Color bgBottom;
  final Color text;
  final Color muted;
  final Color badge;
  final Color border;
  final Color active;
  const _SidebarTokens({
    required this.bgTop,
    required this.bgBottom,
    required this.text,
    required this.muted,
    required this.badge,
    required this.border,
    required this.active,
  });
}
