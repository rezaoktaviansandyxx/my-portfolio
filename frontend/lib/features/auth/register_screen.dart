import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/features/auth/auth_widgets.dart';

/// Halaman /register: satu kartu kaca untuk buat akun, dengan tautan ke login.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            username: _username.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
            fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _error = authErrorMessage(e, 'Gagal mendaftar.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      card: AuthCard(
        title: 'Register',
        subtitle: 'Buat akun dan mulai bangun portofolio.',
        error: _error,
        formKey: _formKey,
        fields: [
          AuthField(
            controller: _name,
            hint: 'Nama lengkap',
            icon: Icons.badge_outlined,
          ),
          AuthField(
            controller: _username,
            hint: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (!RegExp(r'^[a-z0-9_]{3,30}$').hasMatch(t)) {
                return '3-30 karakter: huruf kecil, angka, underscore';
              }
              return null;
            },
          ),
          AuthField(
            controller: _email,
            hint: 'Email',
            icon: Icons.alternate_email_rounded,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          AuthField(
            controller: _password,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            validator: (v) =>
                (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
          ),
        ],
        ctaLabel: 'Register',
        onCta: _busy ? null : _register,
        footer: TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'Sudah punya akun? Login',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ),
    );
  }
}
