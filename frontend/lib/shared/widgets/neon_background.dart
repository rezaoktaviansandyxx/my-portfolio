import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Latar gelap dengan glow radial violet/indigo dan grid tipis.
class NeonBackground extends StatelessWidget {
  final Widget child;
  final bool grid;

  const NeonBackground({super.key, required this.child, this.grid = true});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.bg),
        if (grid)
          const Positioned.fill(child: CustomPaint(painter: _GridPainter())),
        Positioned(
          top: -220,
          left: -160,
          child: _Glow(color: AppColors.violet, size: 620),
        ),
        Positioned(
          top: 120,
          right: -200,
          child: _Glow(color: AppColors.blue, size: 560),
        ),
        Positioned(
          bottom: -260,
          left: 120,
          child: _Glow(color: AppColors.indigo, size: 640),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.028)
      ..strokeWidth = 1;
    const step = 48.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
