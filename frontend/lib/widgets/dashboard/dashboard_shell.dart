import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/theme/app_theme.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final String? badge;
  const SidebarItem({required this.icon, required this.label, this.badge});
}

class DashboardShell extends StatelessWidget {
  final int selectedIndex;
  final List<SidebarItem> menu;
  final ValueChanged<int> onSelect;
  final String displayName;
  final String displayRole;
  final bool isAdminView;
  final bool isAdmin;
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
    required this.isAdminView,
    required this.isAdmin,
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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      backgroundColor: FolioColors.bg,
      drawer: wide ? null : Drawer(child: _sidebar(context, true)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide) SizedBox(width: 272, child: _sidebar(context, false)),
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

  Widget _sidebar(BuildContext context, bool inDrawer) {
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
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FolioColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bangun personal brand',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      'Lihat panduan membuat portofolio yang menarik.',
                      style:
                          TextStyle(color: FolioColors.muted, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Baca panduan →')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topbar(BuildContext context, bool wide) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (!wide)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
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
          if (isAdmin)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _seg(context, 'Admin', isAdminView,
                      () => context.go('/admin')),
                  _seg(context, 'User', !isAdminView,
                      () => context.go('/dashboard')),
                ],
              ),
            ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
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
                    Text(displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(displayRole,
                        style: const TextStyle(
                            color: FolioColors.muted, fontSize: 11)),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  onSelected: (v) {
                    if (v == 'public') context.go('/');
                    if (v == 'logout') context.go('/login');
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'public', child: Text('Lihat situs publik')),
                    PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _seg(
      BuildContext context, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [
                  const BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? FolioColors.primary : FolioColors.muted,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
