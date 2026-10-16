import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/services/auth_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  // Interceptor auth dipasang di AuthNotifier agar selalu pakai token terbaru.
  return dio;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthState {
  final String? token;
  final UserModel? user;
  final bool isLoading;

  const AuthState({this.token, this.user, this.isLoading = false});

  bool get isAuthenticated => token != null;
  bool get isAdmin => user?.isAdmin ?? false;
  AuthState copyWith({String? token, UserModel? user, bool? isLoading}) =>
      AuthState(
        token: token ?? this.token,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Restore async agar tidak block UI; halaman akan redirect setelah token ketemu.
    Future.microtask(_restore);
    return const AuthState(isLoading: true);
  }

  Future<void> _restore() async {
    final service = ref.read(authServiceProvider);
    try {
      final token = await service.loadStoredToken();
      if (token == null) {
        state = const AuthState(isLoading: false);
        return;
      }
      final user = await service.me();
      state = AuthState(token: token, user: user, isLoading: false);
    } catch (_) {
      await service.logout();
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> login(String username, String password) async {
    final service = ref.read(authServiceProvider);
    state = state.copyWith(isLoading: true);
    try {
      final token = await service.login(username, password);
      final user = await service.me();
      state = AuthState(token: token, user: user, isLoading: false);
    } catch (e) {
      state = const AuthState(isLoading: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    final service = ref.read(authServiceProvider);
    await service.logout();
    state = const AuthState(isLoading: false);
    ref.invalidate(authServiceProvider);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Kompatibilitas dengan kode lama yang masih memakai authStateProvider.
final authStateProvider = Provider<AuthState>((ref) => ref.watch(authNotifierProvider));
final isAuthProvider = Provider<bool>((ref) => ref.watch(authNotifierProvider).isAuthenticated);
