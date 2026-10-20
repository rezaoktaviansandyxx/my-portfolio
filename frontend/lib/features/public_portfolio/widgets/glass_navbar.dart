import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glow_button.dart';

class NavTarget {
  final String label;
  final GlobalKey anchor;

  const NavTarget({required this.label, required this.anchor});
}

/// Navbar lengket dengan latar kaca. Pil aktif digarisbawahi.
class GlassNavbar extends StatelessWidget {
  final List<NavTarget> items;
  final ValueChanged<int> onSelect;
  final int activeIndex;
  final VoidCallback? onHireMe;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onGalleryTap;

  const GlassNavbar({
    super.key,
    required this.items,
    required this.onSelect,
    required this.activeIndex,
    this.onHireMe,
    this.avatarUrl,
    this.initials,
    this.onAvatarTap,
    this.onMenuTap,
    this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 900;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1020).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              _Logo(initials: initials),
              if (wide) ...[
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _NavPill(
                          label: items[i].label,
                          active: i == activeIndex,
                          onTap: () => onSelect(i),
                        ),
                    ],
                  ),
                ),
                if (onHireMe != null)
                  GlowButton(
                    label: 'Hire Me',
                    icon: Icons.send_rounded,
                    onPressed: onHireMe,
                  ),
                const SizedBox(width: 10),
                _Avatar(
                  url: avatarUrl,
                  initials: initials,
                  onTap: onAvatarTap,
                ),
              ] else ...[
                const Spacer(),
                if (onGalleryTap != null)
                  IconButton(
                    onPressed: onGalleryTap,
                    icon: const Icon(Icons.grid_view_rounded),
                    color: AppColors.ink,
                    tooltip: 'Galeri',
                  ),
                IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(Icons.menu_rounded),
                  color: AppColors.ink,
                  tooltip: 'Menu',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String? initials;

  const _Logo({this.initials});

  @override
  Widget build(BuildContext context) {
    final text = (initials == null || initials!.isEmpty) ? 'F' : initials!;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'FolioSpace',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.ink : AppColors.muted,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 2,
                width: active ? 18 : 0,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String? initials;
  final VoidCallback? onTap;

  const _Avatar({this.url, this.initials, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
          ),
          child: ClipOval(
            child: AppNetworkImage(url: url, width: 36, height: 36),
          ),
        ),
      ),
    );
  }
}
