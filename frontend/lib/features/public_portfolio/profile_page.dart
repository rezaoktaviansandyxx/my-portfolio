import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:frontend/core/models/public_profile_model.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/network/app_providers.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/features/public_portfolio/widgets/contact_section.dart';
import 'package:frontend/features/public_portfolio/widgets/experience_timeline.dart';
import 'package:frontend/features/public_portfolio/widgets/glass_navbar.dart';
import 'package:frontend/features/public_portfolio/widgets/hero_section.dart';
import 'package:frontend/features/public_portfolio/widgets/project_showcase_dialog.dart';
import 'package:frontend/features/public_portfolio/widgets/projects_grid.dart';
import 'package:frontend/features/public_portfolio/widgets/skills_section.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';
import 'package:frontend/shared/widgets/skeleton.dart';

/// Halaman publik portofolio kreator: "/u/:slug".
class ProfileScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProfileScreen({super.key, required this.slug});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scroll = ScrollController();
  final _anchors = List.generate(6, (_) => GlobalKey());
  int _active = 0;

  /// Anchor 0..5: Home, About, Projects, Skills, Experience, Contact.
  /// Skills & Experience dipisah agar bottom nav punya empat tujuan nyata.
  static const _bottomAnchors = [0, 2, 3, 4];

  /// Posisi item navbar desktop: Skills & Experience berbagi "Expertise",
  /// section Contact tidak punya item navbar (diarahkan ke "Expertise").
  int get _desktopActive {
    if (_active <= 3) return _active;
    return 3;
  }

  /// Indeks item bottom nav untuk anchor yang sedang aktif.
  int get _bottomActive {
    var best = 0;
    var bestAnchor = -1;
    for (var i = 0; i < _bottomAnchors.length; i++) {
      final a = _bottomAnchors[i];
      if (a <= _active && a > bestAnchor) {
        bestAnchor = a;
        best = i;
      }
    }
    return best;
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_spy);
  }

  @override
  void dispose() {
    _scroll.removeListener(_spy);
    _scroll.dispose();
    super.dispose();
  }

  /// Section dianggap aktif bila tepi atasnya sudah melewati 140px.
  void _spy() {
    var next = 0;
    for (var i = 0; i < _anchors.length; i++) {
      final ctx = _anchors[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy < 140) next = i;
    }
    if (next != _active) setState(() => _active = next);
  }

  void _goTo(int index) {
    final ctx = _anchors[index].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launcher.launchUrl(
      uri,
      mode: launcher.LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL disalin ke clipboard')),
      );
    }
  }

  String _errorMessage(Object e) {
    if (e is ApiException) {
      if (e.isNotFound) {
        return 'Profil "${widget.slug}" tidak ditemukan atau belum dipublish.';
      }
      return 'Gagal memuat profil: ${e.message}';
    }
    return 'Gagal terhubung ke server.';
  }

  @override
  Widget build(BuildContext context) {
    final slug = widget.slug;
    final profile = ref.watch(userProfileProvider(slug));
    final auth = ref.watch(authNotifierProvider);

    final wide = MediaQuery.sizeOf(context).width > kDesktopBreakpoint;
    return Scaffold(
      bottomNavigationBar: wide ? null : _mobileNav(),
      body: NeonBackground(
        child: SafeArea(
          bottom: false,
          child: profile.when(
            data: (user) => _content(user, auth.isAuthenticated),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  ProfileCardSkeleton(),
                  SizedBox(height: 14),
                  ListSkeleton(rows: 3),
                ],
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ErrorCard(
                  message: _errorMessage(e),
                  onRetry: () => ref.invalidate(userProfileProvider(slug)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(PublicProfileModel user, bool isAuth) {
    final slug = widget.slug;
    final name = (user.fullName ?? user.username).trim();
    final initials = initialsOf(name);
    final wide = MediaQuery.sizeOf(context).width > kDesktopBreakpoint;

    final navItems = [
      NavTarget(label: 'Home', anchor: _anchors[0]),
      NavTarget(label: 'About', anchor: _anchors[1]),
      NavTarget(label: 'Projects', anchor: _anchors[2]),
      NavTarget(label: 'Expertise', anchor: _anchors[3]),
    ];

    final body = CustomScrollView(
      controller: _scroll,
      slivers: [
        // Navbar sticky: tetap tampil di atas saat halaman discroll.
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyNavbarDelegate(
            height: MediaQuery.textScalerOf(context)
                .scale(wide ? 68.0 : 64.0),
            navbar: GlassNavbar(
              items: navItems,
              activeIndex: _desktopActive,
              onSelect: _goTo,
              onHireMe: () => _goTo(5),
              avatarUrl: user.avatarUrl,
              initials: initials,
              onAvatarTap: () =>
                  context.go(isAuth ? '/dashboard' : '/login'),
              onGalleryTap: () => context.go('/gallery'),
              onMenuTap: () => _showSheet(isAuth),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    KeyedSubtree(
                      key: _anchors[0],
                      child: HeroSection(
                        user: user,
                        onHireMe: () => _goTo(5),
                        onOpenUrl: _openUrl,
                      ),
                    ),
                    const SizedBox(height: 26),
                    KeyedSubtree(
                      key: _anchors[1],
                      child: _section(
                        title: 'About',
                        eyebrow: 'TENTANG',
                        child: Text(
                          (user.bio ?? '').isEmpty
                              ? 'Belum ada deskripsi.'
                              : user.bio!,
                          style: AppText.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    KeyedSubtree(key: _anchors[2], child: _projects(slug)),
                    const SizedBox(height: 26),
                    _skills(slug),
                    const SizedBox(height: 26),
                    KeyedSubtree(
                      key: _anchors[5],
                      child: ContactSection(slug: slug),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return ResponsiveLayout(
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SideRail(),
          Expanded(child: body),
        ],
      ),
      mobile: body,
    );
  }

  Widget _section({
    required String title,
    required String eyebrow,
    required Widget child,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppText.eyebrow),
          const SizedBox(height: 6),
          Text(title, style: AppText.title.copyWith(fontSize: 22)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _projects(String slug) {
    final async = ref.watch(userProjectsProvider(slug));
    return _section(
      title: 'Projects',
      eyebrow: 'KARYA',
      child: async.when(
        data: (projects) => projects.isEmpty
            ? const Text('Belum ada proyek.', style: AppText.body)
            : ProjectsGrid(
                projects: projects.take(12).toList(),
                onOpen: (p) => ProjectShowcaseDialog.show(context, p, _openUrl),
              ),
        loading: () => const ListSkeleton(rows: 2),
        error: (e, _) => ErrorCard(
          message: 'Gagal memuat proyek: $e',
          onRetry: () => ref.invalidate(userProjectsProvider(slug)),
        ),
      ),
    );
  }

  Widget _skills(String slug) {
    final async = ref.watch(userSkillsProvider(slug));
    final expAsync = ref.watch(userExperiencesProvider(slug));
    return _section(
      title: 'Expertise',
      eyebrow: 'KEAHLIAN',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KeyedSubtree(
            key: _anchors[3],
            child: async.when(
              data: (skills) => skills.isEmpty
                  ? const Text('Belum ada skill.', style: AppText.body)
                  : SkillsSection(skills: skills),
              loading: () => const SkillChipsSkeleton(),
              error: (e, _) =>
                  Text('Gagal memuat skill: $e', style: AppText.caption),
            ),
          ),
          const SizedBox(height: 22),
          KeyedSubtree(
            key: _anchors[4],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Experience Timeline', style: AppText.heading),
                const SizedBox(height: 14),
                expAsync.when(
                  data: (items) => items.isEmpty
                      ? const Text(
                          'Belum ada pengalaman.',
                          style: AppText.body,
                        )
                      : ExperienceTimeline(
                          experiences: items.take(10).toList(),
                        ),
                  loading: () => const ListSkeleton(rows: 3),
                  error: (e, _) => Text(
                    'Gagal memuat pengalaman: $e',
                    style: AppText.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Menu mobile hanya berisi aksi akun & galeri — navigasi antar-section
  /// sudah ditangani bottom navigation bar.
  void _showSheet(bool isAuth) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0C1226),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: Text(isAuth ? 'Dashboard' : 'Login pemilik'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(isAuth ? '/dashboard' : '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/gallery');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom navigation bar khusus mobile (bukan drawer).
  Widget _mobileNav() {
    return NavigationBar(
      selectedIndex: _bottomActive,
      onDestinationSelected: (i) => _goTo(_bottomAnchors[i]),
      backgroundColor: const Color(0xFF0A1020),
      indicatorColor: AppColors.indigo.withValues(alpha: 0.35),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Projects',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          selectedIcon: Icon(Icons.auto_awesome_rounded),
          label: 'Skills',
        ),
        NavigationDestination(
          icon: Icon(Icons.timeline_outlined),
          selectedIcon: Icon(Icons.timeline_rounded),
          label: 'Experience',
        ),
      ],
    );
  }
}

/// Rail tipis di kiri layar desktop: logo + pintasan galeri.
class _SideRail extends StatelessWidget {
  const _SideRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      margin: const EdgeInsets.fromLTRB(12, 16, 0, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.go('/gallery'),
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            color: AppColors.muted,
            tooltip: 'Galeri',
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// Delegate header navbar sticky. Saat discroll, jarak atas 16px menyusut
/// hingga navbar menempel rapi di tepi atas lalu tetap tersemat (pinned).
class _StickyNavbarDelegate extends SliverPersistentHeaderDelegate {
  _StickyNavbarDelegate({required this.navbar, required this.height});

  final Widget navbar;

  /// Tinggi navbar; dipakai sebagai extent minimum saat sudah tersemat.
  final double height;

  static const _topGap = 16.0;

  @override
  double get maxExtent => height + _topGap;

  @override
  double get minExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: navbar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyNavbarDelegate oldDelegate) =>
      navbar != oldDelegate.navbar || height != oldDelegate.height;
}
