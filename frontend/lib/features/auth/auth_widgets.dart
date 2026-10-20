import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/neon_background.dart';

/// Shell halaman auth: latar neon + brand FolioSpace + satu kartu di tengah.
/// Dipakai bersama LoginScreen dan RegisterScreen agar tampilan konsisten.
class AuthPageShell extends StatelessWidget {
  final Widget card;

  const AuthPageShell({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    const AuthBrand(),
                    const SizedBox(height: 32),
                    card,
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
}

class AuthBrand extends StatelessWidget {
  const AuthBrand({super.key});

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

class AuthField {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;

  const AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
  });
}

class AuthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? error;
  final GlobalKey<FormState> formKey;
  final List<AuthField> fields;
  final String ctaLabel;
  final VoidCallback? onCta;
  final Widget footer;

  const AuthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.error,
    required this.formKey,
    required this.fields,
    required this.ctaLabel,
    required this.onCta,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
              AuthErrorNote(message: error!),
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
    );
  }
}

class AuthErrorNote extends StatelessWidget {
  final String message;

  const AuthErrorNote({super.key, required this.message});

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

/// Konversi exception API jadi pesan ramah pengguna (rate limit, dsb).
String authErrorMessage(Object e, String fallback) {
  if (e is ApiException) {
    if (e.isRateLimited) {
      return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return e.message;
  }
  return fallback;
}
