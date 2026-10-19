import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

/// Permukaan kaca: blur + fill putih transparan + border tipis.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool blur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppTheme.radiusCard,
    this.gradient,
    this.onTap,
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.glassFill : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );

    final surface = blur
        ? ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: content,
            ),
          )
        : content;

    if (onTap == null) return surface;
    return HoverScale(onTap: onTap, child: surface);
  }
}
