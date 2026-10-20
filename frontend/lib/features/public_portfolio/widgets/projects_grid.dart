import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glass_card.dart';
import 'package:frontend/shared/widgets/hover_scale.dart';

/// Grid proyek: jumlah kolom diturunkan dari lebar, bukan hardcoded.
class ProjectsGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  final void Function(ProjectModel) onOpen;

  const ProjectsGrid({
    super.key,
    required this.projects,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 250,
      ),
      itemCount: projects.length,
      itemBuilder: (_, i) => _ProjectCard(
        project: projects[i],
        onTap: () => onOpen(projects[i]),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HoverScale(
      onTap: onTap,
      child: GlassCard(
        blur: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AppNetworkImage(
                url: project.coverImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.summary ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.body,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final s in (project.skills ?? []).take(3))
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.indigoSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s.name,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.body,
                            ),
                          ),
                        ),
                      const Spacer(),
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
