import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.delta,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: iconColor),
                ),
                const Spacer(),
                const Icon(Icons.more_horiz, color: FolioColors.muted),
              ],
            ),
            const SizedBox(height: 18),
            Text(label, style: const TextStyle(color: FolioColors.muted)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: FolioColors.greenBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('↗ $delta',
                      style: const TextStyle(
                          color: FolioColors.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!,
                            style: const TextStyle(
                                color: FolioColors.muted, fontSize: 13)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String text;
  const StatusPill(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    final published = text.toLowerCase() == 'published';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: published ? FolioColors.greenBg : const Color(0xFFF1F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              color: published ? FolioColors.green : FolioColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12)),
    );
  }
}

class GrowthChart extends StatelessWidget {
  final List<double> values;
  const GrowthChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: double.infinity,
          child: CustomPaint(painter: _AreaPainter(values)),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Jan', style: _axis),
            Text('Feb', style: _axis),
            Text('Mar', style: _axis),
            Text('Apr', style: _axis),
            Text('Mei', style: _axis),
            Text('Jun', style: _axis),
          ],
        ),
      ],
    );
  }

  static const _axis =
      TextStyle(color: FolioColors.muted, fontSize: 12);
}

class _AreaPainter extends CustomPainter {
  final List<double> values;
  _AreaPainter(this.values);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final pts = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height -
          ((values[i] - minV) / span) * (size.height * 0.8) -
          size.height * 0.1;
      pts.add(Offset(x, y));
    }
    final line = Paint()
      ..color = FolioColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      final mid = (pts[i - 1] + pts[i]) / 2;
      path.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, mid.dx, mid.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, line);
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FolioColors.primary.withValues(alpha: 0.22),
              FolioColors.primary.withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill);
    for (final p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = Colors.white);
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = FolioColors.primary
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow,
                  style: const TextStyle(
                      color: FolioColors.primary,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(title,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: FolioColors.muted)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add, size: 18),
          label: Text(actionLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: FolioColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}
