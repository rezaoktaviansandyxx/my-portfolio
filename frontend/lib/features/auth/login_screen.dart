import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/features/auth/auth_widgets.dart';

/// Halaman /login: satu kartu kaca untuk masuk, dengan tautan ke register.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _username = TextEditingController();
  final _password = TextEditingController();

  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_username.text.trim(), _password.text);
      if (!mounted) return;
      final auth = ref.read(authNotifierProvider);
      context.go(auth.isAdmin ? '/admin' : '/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _error = authErrorMessage(e, 'Gagal masuk.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      card: AuthCard(
        title: 'Login',
        subtitle: 'Masuk untuk mengelola portofolio.',
        error: _error,
        formKey: _formKey,
        fields: [
          AuthField(
            controller: _username,
            hint: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
          ),
          AuthField(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
          ),
        ],
        ctaLabel: 'Login',
        onCta: _busy ? null : _login,
        footer: TextButton(
          onPressed: () => context.go('/register'),
          child: const Text(
            'Belum punya akun? Register',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}
