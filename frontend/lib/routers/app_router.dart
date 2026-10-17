import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/providers/auth_providers.dart';
import 'package:frontend/widgets/profile_screen.dart';
import 'package:frontend/widgets/gallery_screen.dart';
import 'package:frontend/widgets/auth/login_screen.dart';
import 'package:frontend/widgets/auth/register_screen.dart';
import 'package:frontend/widgets/user/user_dashboard.dart';
import 'package:frontend/widgets/admin/admin_dashboard.dart';

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
      // Publik: '/' dan '/u/:slug' boleh tanpa token (portofolio).
      // Kalau mau full-private, uncomment 2 baris ini:
      // if (!isAuth) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const ProfileScreen(slug: 'admin'),
      ),
      GoRoute(
        path: '/u/:slug',
        builder: (_, s) =>
            ProfileScreen(slug: s.pathParameters['slug'] ?? 'admin'),
      ),
      GoRoute(path: '/gallery', builder: (_, __) => const GalleryScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isAuthenticated) {
      // Gate: belum ada access_token -> ke login dulu
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (adminOnly && !auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go('/dashboard'),
      );
      return const Scaffold(body: Center(child: Text('Butuh role admin...')));
    }
    return child;
  }
}
