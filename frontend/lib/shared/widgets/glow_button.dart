import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

enum GlowButtonVariant { filled, glass, ghost }

class GlowButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GlowButtonVariant variant;
  final bool expand;

  const GlowButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GlowButtonVariant.filled,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final fg = switch (variant) {
      GlowButtonVariant.filled => Colors.white,
      GlowButtonVariant.glass => AppColors.ink,
      GlowButtonVariant.ghost => AppColors.cyan,
    };

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: variant == GlowButtonVariant.ghost ? 12 : 20,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        gradient: variant == GlowButtonVariant.filled
            ? AppColors.brandGradient
            : null,
        color: variant == GlowButtonVariant.glass
            ? Colors.white.withValues(alpha: 0.07)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: variant == GlowButtonVariant.glass
            ? Border.all(color: AppColors.glassBorderStrong)
            : null,
        boxShadow: variant == GlowButtonVariant.filled && !disabled
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.45),
                  blurRadius: 22,
                  spreadRadius: -6,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: HoverScale(
        onTap: disabled ? null : onPressed,
        lift: 2,
        scale: 1.01,
        child: content,
      ),
    );
  }
}
