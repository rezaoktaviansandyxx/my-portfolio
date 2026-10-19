import 'package:flutter/material.dart';
import 'package:frontend/shared/widgets/skill_gradient.dart';

class NeonChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const NeonChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final g = skillGradient(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            g.colors.first.withValues(alpha: 0.85),
            g.colors.last.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: g.colors.last.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
