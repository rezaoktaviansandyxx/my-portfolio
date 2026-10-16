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
      backgroundColor: FolioColors.bg,
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
    return Container(
      color: Colors.white,
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
                      color: FolioColors.ink,
                      borderRadius: BorderRadius.circular(12),
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
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('Portfolio builder',
                            style: TextStyle(
                                color: FolioColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (inDrawer)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Menu utama',
                  style: TextStyle(color: FolioColors.muted, fontSize: 12)),
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
                          ? FolioColors.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: active
                          ? Border.all(
                              color: FolioColors.primary
                                  .withValues(alpha: 0.25))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(m.icon,
                            size: 20,
                            color: active
                                ? FolioColors.primary
                                : FolioColors.muted),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(m.label,
                              style: TextStyle(
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? FolioColors.ink
                                      : const Color(0xFF374151))),
                        ),
                        if (m.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: active
                                  ? FolioColors.primary
                                  : const Color(0xFFEEF0F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(m.badge!,
                                style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : FolioColors.muted,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: OutlinedButton.icon(
                onPressed: () => _doLogout(context, ref),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB42318),
                  side: const BorderSide(color: Color(0xFFF0C6C2)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FolioColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bangun personal brand',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text(
                      'Lihat panduan membuat portofolio yang menarik.',
                      style:
                          TextStyle(color: FolioColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topbar(BuildContext context, WidgetRef ref, bool wide) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: FolioColors.border)),
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
                icon: const Icon(Icons.notifications_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF6F7FB),
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
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
              border: Border.all(color: FolioColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: FolioColors.peachBg,
                  child: Text(_initials,
                      style: const TextStyle(
                          color: FolioColors.peachInk,
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
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                    Text(displayRole,
                        style: const TextStyle(
                            color: FolioColors.muted, fontSize: 11)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  tooltip: 'Akun',
                  onSelected: (v) {
                    if (v == 'public') context.go('/');
                    if (v == 'logout') _doLogout(context, ref);
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
