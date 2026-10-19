import 'package:flutter/material.dart';
import 'package:frontend/core/models/skill_model.dart';
import 'package:frontend/shared/widgets/neon_chip.dart';

class SkillsSection extends StatelessWidget {
  final List<SkillModel> skills;

  const SkillsSection({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final s in skills)
          NeonChip(label: s.name, icon: _iconFor(s.category)),
      ],
    );
  }

  IconData? _iconFor(String? category) {
    switch ((category ?? '').toLowerCase()) {
      case 'frontend':
        return Icons.web_rounded;
      case 'backend':
        return Icons.dns_outlined;
      case 'database':
        return Icons.storage_rounded;
      case 'tools':
        return Icons.terminal_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }
}
