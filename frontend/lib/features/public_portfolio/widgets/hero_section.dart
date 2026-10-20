import 'package:flutter/material.dart';
import 'package:frontend/core/models/user_model.dart';
import 'package:frontend/core/network/api_config.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/core/utils/validators.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/glow_button.dart';
import 'package:frontend/shared/widgets/responsive_layout.dart';

class HeroSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onHireMe;
  final void Function(String url) onOpenUrl;

  const HeroSection({
    super.key,
    required this.user,
    required this.onHireMe,
    required this.onOpenUrl,
  });

  String get _name =>
      (user.fullName ?? '').trim().isEmpty ? user.username : user.fullName!.trim();

  String get _initials => initialsOf(_name);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: ResponsiveLayout(
        desktop: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(url: user.avatarUrl, initials: _initials, size: 116),
            const SizedBox(width: 24),
            Expanded(child: _identity(compact: false)),
            const SizedBox(width: 24),
            SizedBox(width: 190, child: _actions()),
          ],
        ),
        mobile: Column(
          children: [
            _Avatar(url: user.avatarUrl, initials: _initials, size: 92),
            const SizedBox(height: 16),
            _identity(compact: true),
            const SizedBox(height: 18),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _identity({required bool compact}) {
    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          _name,
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: AppText.display.copyWith(fontSize: compact ? 26 : 34),
        ),
        const SizedBox(height: 6),
        Text(
          (user.headline ?? '').trim().isEmpty
              ? 'Full-Stack Developer'
              : user.headline!,
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        if ((user.bio ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            user.bio!,
            maxLines: compact ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: AppText.body,
          ),
        ],
        const SizedBox(height: 14),
        _Socials(
          email: user.email,
          onOpenUrl: onOpenUrl,
          centered: compact,
        ),
      ],
    );
  }

  Widget _actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlowButton(
          label: 'Hire Me',
          icon: Icons.send_rounded,
          onPressed: onHireMe,
          expand: true,
        ),
        if ((user.resumeUrl ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          GlowButton(
            label: 'Download CV',
            icon: Icons.download_rounded,
            variant: GlowButtonVariant.glass,
            onPressed: () =>
                onOpenUrl(ApiConfig.resolveFileUrl(user.resumeUrl)),
            expand: true,
          ),
        ],
        const SizedBox(height: 10),
        GlowButton(
          label: 'Email',
          icon: Icons.mail_outline_rounded,
          variant: GlowButtonVariant.ghost,
          onPressed: () => onOpenUrl('mailto:${user.email}'),
          expand: true,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  final double size;

  const _Avatar({
    required this.url,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.5),
            blurRadius: 34,
            spreadRadius: -6,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg,
        ),
        child: (url ?? '').isEmpty
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.indigo.withValues(alpha: 0.25),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: size * 0.34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              )
            : AppNetworkImage(
                url: url,
                width: size,
                height: size,
                shape: BoxShape.circle,
              ),
      ),
    );
  }
}

class _Socials extends StatelessWidget {
  final String email;
  final void Function(String) onOpenUrl;
  final bool centered;

  const _Socials({
    required this.email,
    required this.onOpenUrl,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    // Hanya email: model User belum punya field github/linkedin, jadi ikon
    // sosial lain tidak dirender — URL dummy ke beranda platform akan terasa
    // seperti bug. Tambahkan kembali begitu field sosial tersedia di model.
    final items = <(IconData, String)>[
      (Icons.mail_outline_rounded, 'mailto:$email'),
    ];

    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        for (final (icon, url) in items)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onOpenUrl(url),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Icon(icon, size: 15, color: AppColors.body),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
