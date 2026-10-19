import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Membungkus child dengan kursor click + animasi naik saat hover.
class HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lift;
  final double scale;

  const HoverScale({
    super.key,
    required this.child,
    this.onTap,
    this.lift = 4,
    this.scale = 1.0,
  });

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, _hovered ? -widget.lift : 0, 0),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: AppColors.indigo.withValues(alpha: 0.28),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: _hovered && widget.scale != 1.0
          ? Transform.scale(scale: widget.scale, child: widget.child)
          : widget.child,
    );

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: body,
      ),
    );
  }
}
