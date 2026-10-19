import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/features/auth/auth_providers.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/neon_background.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

/// Satu layar untuk /login dan /register: dua kartu kaca berdampingan,
/// kartu yang sesuai rute menyala.
class AuthScreen extends ConsumerStatefulWidget {
  final bool registerMode;

  const AuthScreen({super.key, required this.registerMode});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginUser = TextEditingController();
  final _loginPass = TextEditingController();
  final _regName = TextEditingController();
  final _regUser = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPass = TextEditingController();

  String? _loginError;
  String? _registerError;
  bool _busy = false;

  @override
  void dispose() {
    _loginUser.dispose();
    _loginPass.dispose();
    _regName.dispose();
    _regUser.dispose();
    _regEmail.dispose();
    _regPass.dispose();
    super.dispose();
  }

  String _message(Object e, String fallback) {
    if (e is ApiException) {
      if (e.isRateLimited) {
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
      }
      return e.message;
    }
    return fallback;
  }

  Future<void> _login() async {
    if (!(_loginKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _loginError = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(_loginUser.text.trim(), _loginPass.text);
      if (!mounted) return;
      final auth = ref.read(authNotifierProvider);
      context.go(auth.isAdmin ? '/admin' : '/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _loginError = _message(e, 'Gagal masuk.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    if (!(_registerKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _registerError = null;
    });
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .register(
            username: _regUser.text.trim(),
            email: _regEmail.text.trim(),
            password: _regPass.text,
            fullName: _regName.text.trim().isEmpty
                ? null
                : _regName.text.trim(),
          );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _registerError = _message(e, 'Gagal mendaftar.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    const _Brand(),
                    const SizedBox(height: 32),
                    ResponsiveLayout(
                      desktop: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _loginCard(active: !widget.registerMode),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _registerCard(active: widget.registerMode),
                          ),
                        ],
                      ),
                      mobile: Column(
                        children: [
                          _loginCard(active: !widget.registerMode),
                          const SizedBox(height: 20),
                          _registerCard(active: widget.registerMode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextButton(
                      onPressed: () => context.go('/gallery'),
                      child: const Text('Jelajahi galeri tanpa akun'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginCard({required bool active}) {
    return _AuthCard(
      title: 'Login',
      subtitle: 'Masuk untuk mengelola portofolio.',
      active: active,
      error: _loginError,
      formKey: _loginKey,
      fields: [
        _Field(
          controller: _loginUser,
          hint: 'Username',
          icon: Icons.person_outline_rounded,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
        ),
        _Field(
          controller: _loginPass,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
        ),
      ],
      ctaLabel: 'Login',
      onCta: _busy ? null : _login,
      footer: const Text(
        'Lupa password?',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    );
  }

  Widget _registerCard({required bool active}) {
    return _AuthCard(
      title: 'Register',
      subtitle: 'Buat akun dan mulai bangun portofolio.',
      active: active,
      error: _registerError,
      formKey: _registerKey,
      fields: [
        _Field(
          controller: _regName,
          hint: 'Nama lengkap',
          icon: Icons.badge_outlined,
        ),
        _Field(
          controller: _regUser,
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
        _Field(
          controller: _regEmail,
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
        _Field(
          controller: _regPass,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
          validator: (v) =>
              (v == null || v.length < 8) ? 'Minimal 8 karakter' : null,
        ),
      ],
      ctaLabel: 'Register',
      onCta: _busy ? null : _register,
      footer: Text(
        'Sudah punya akun?',
        style: const TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.indigo.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'F',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'FolioSpace',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _Field {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
  });
}

class _AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool active;
  final String? error;
  final GlobalKey<FormState> formKey;
  final List<_Field> fields;
  final String ctaLabel;
  final VoidCallback? onCta;
  final Widget footer;

  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.error,
    required this.formKey,
    required this.fields,
    required this.ctaLabel,
    required this.onCta,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: active
              ? AppColors.cyan.withValues(alpha: 0.55)
              : Colors.transparent,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.35),
                  blurRadius: 40,
                  spreadRadius: -8,
                ),
              ]
            : null,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppText.title.copyWith(fontSize: 24)),
              const SizedBox(height: 4),
              Text(subtitle, style: AppText.caption),
              const SizedBox(height: 20),
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                TextFormField(
                  controller: fields[i].controller,
                  obscureText: fields[i].obscure,
                  validator: fields[i].validator,
                  decoration: InputDecoration(
                    hintText: fields[i].hint,
                    prefixIcon: Icon(fields[i].icon, size: 19),
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 14),
                _ErrorNote(message: error!),
              ],
              const SizedBox(height: 20),
              GlowButton(
                label: ctaLabel,
                onPressed: onCta,
                expand: true,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: 6),
              Center(child: footer),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;

  const _ErrorNote({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
