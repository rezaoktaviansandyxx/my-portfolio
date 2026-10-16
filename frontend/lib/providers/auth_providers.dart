import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:dio/dio.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(dioProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthService(dio);
});

class AuthState {
  final bool isAuthenticated;
  final AuthService service;

  AuthState(this.service) : isAuthenticated = service.isAuthenticated;

  Future<AuthState> login(String username, String password) async {
    await service.login(username, password);
    return AuthState(service);
  }

  AuthState logout() {
    service.logout();
    return AuthState(service);
  }
}

final authStateProvider = StateProvider<AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthState(service);
});

final isAuthProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});
