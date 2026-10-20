import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/features/public_portfolio/profile_page.dart';
import 'package:frontend/features/gallery/gallery_page.dart';
import 'package:frontend/shared/widgets/skeleton.dart';
import 'package:frontend/features/auth/login_screen.dart';
import 'package:frontend/features/auth/register_screen.dart';
import 'package:frontend/features/dashboard_me/user_dashboard_page.dart';
import 'package:frontend/features/admin/admin_dashboard_page.dart';

/// Notifier agar GoRouter re-evaluasi redirect setiap auth berubah
/// (login/logout/restore token). Tanpa ini gate telat jalan di web.
class RouterRefresh extends ChangeNotifier {
  RouterRefresh(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) => notifyListeners());
  }
}

final routerRefreshProvider = Provider<RouterRefresh>(
  (ref) => RouterRefresh(ref),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      // Saat restore token (baca localStorage) jangan redirect dulu,
      // tampilkan splash agar tidak flicker ke dashboard tanpa token.
      if (auth.isLoading) return null;
      final isAuth = auth.isAuthenticated;
      final isAdmin = auth.isAdmin;
      final path = state.matchedLocation;

      // HOME "/": tampilkan situs publik milik pengguna sendiri.
      // Kalau belum login atau slug belum diset, fallback ke galeri kreator.
      // (Sebelumnya "/" hardcoded ke slug 'admin' sehingga selalu memuat
      // profil admin, bukan profil kreator yang dipublish.)
      if (path == '/') {
        final slug = auth.user?.profileSlug;
        final hasOwnSite = isAuth && slug != null && slug.trim().isNotEmpty;
        return hasOwnSite ? '/u/$slug' : '/gallery';
      }

      // GATE: semua halaman privat wajib access_token
      if (path == '/dashboard' || path.startsWith('/dashboard/')) {
        if (!isAuth) return '/login';
        return null;
      }
      if (path == '/admin' || path.startsWith('/admin/')) {
        if (!isAuth) return '/login';
        if (!isAdmin) return '/dashboard';
        return null;
      }
      if (path == '/login' || path == '/register') {
        if (!isAuth) return null;
        return isAdmin ? '/admin' : '/dashboard';
      }
      // Publik: '/u/:slug' dan '/gallery' boleh tanpa token (portofolio).
      // "/" di-handle di atas (redirect ke situs sendiri / galeri).
      // Kalau mau full-private, uncomment 2 baris ini:
      // if (!isAuth) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        // Hanya tampil sesaat saat restore token (isLoading), karena
        // redirect di atas langsung antarkan ke /u/<slug> atau /gallery.
        builder: (_, __) => const PageSkeleton(),
      ),
      GoRoute(
        path: '/u/:slug',
        builder: (_, s) => ProfileScreen(slug: s.pathParameters['slug']!),
      ),
      GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, __) =>
            const _AuthGate(adminOnly: false, child: UserDashboard()),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) =>
            const _AuthGate(adminOnly: true, child: AdminDashboard()),
      ),
    ],
    errorBuilder: (_, s) => Scaffold(
      body: Center(child: Text('404 - ${s.matchedLocation} tidak ditemukan')),
    ),
  );
});

/// Defense-in-depth: walau redirect lolos (misal saat isLoading),
/// halaman privat tidak pernah render tanpa token.
class _AuthGate extends ConsumerWidget {
  final Widget child;
  final bool adminOnly;
  const _AuthGate({required this.child, required this.adminOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    if (auth.isLoading) {
      return const PageSkeleton();
    }
    if (!auth.isAuthenticated) {
      // Gate: belum ada access_token -> ke login dulu.
      // Guard mounted: callback bisa jalan setelah widget sudah dispose.
      final ctx = context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctx.mounted) context.go('/login');
      });
      return const PageSkeleton();
    }
    if (adminOnly && !auth.isAdmin) {
      final ctx = context;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctx.mounted) context.go('/dashboard');
      });
      return const Scaffold(body: Center(child: Text('Butuh role admin...')));
    }
    return child;
  }
}
