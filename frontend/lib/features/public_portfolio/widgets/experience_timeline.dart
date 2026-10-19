import 'package:flutter/material.dart';
import 'package:frontend/core/models/experience_model.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Timeline dengan gutter tanggal di kiri, garis + titik di tengah.
class ExperienceTimeline extends StatelessWidget {
  final List<ExperienceModel> experiences;

  const ExperienceTimeline({super.key, required this.experiences});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String _stamp(DateTime? d) =>
      d == null ? '—' : '${d.day} ${_months[d.month - 1]} ${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < experiences.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 92,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: Text(
                      _stamp(experiences[i].startDate),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 18,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cyan.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      if (i < experiences.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experiences[i].role,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          experiences[i].company,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((experiences[i].description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            experiences[i].description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.5,
                              color: AppColors.body,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
