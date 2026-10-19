import 'package:flutter/material.dart';
import 'package:frontend/core/models/project_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_text.dart';
import 'package:frontend/shared/widgets/app_network_image.dart';
import 'package:frontend/shared/widgets/glow_button.dart';

class ProjectShowcaseDialog extends StatefulWidget {
  final ProjectModel project;
  final void Function(String url) onOpenUrl;

  const ProjectShowcaseDialog({
    super.key,
    required this.project,
    required this.onOpenUrl,
  });

  static Future<void> show(
    BuildContext context,
    ProjectModel project,
    void Function(String url) onOpenUrl,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => ProjectShowcaseDialog(
        project: project,
        onOpenUrl: onOpenUrl,
      ),
    );
  }

  @override
  State<ProjectShowcaseDialog> createState() => _ProjectShowcaseDialogState();
}

class _ProjectShowcaseDialogState extends State<ProjectShowcaseDialog> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _media {
    return <String>[
      if ((widget.project.coverImageUrl ?? '').isNotEmpty)
        widget.project.coverImageUrl!,
      ...(widget.project.media ?? []).map((m) => m.mediaUrl),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final media = _media;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width > 900;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 860,
          maxHeight: size.height * 0.88,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: wide ? 16 / 8 : 16 / 10,
                    child: media.isEmpty
                        ? Container(
                            color: Colors.white.withValues(alpha: 0.05),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_outlined,
                              size: 44,
                              color: AppColors.muted,
                            ),
                          )
                        : PageView.builder(
                            controller: _controller,
                            onPageChanged: (i) => setState(() => _index = i),
                            itemCount: media.length,
                            itemBuilder: (_, i) => AppNetworkImage(
                              url: media[i],
                              width: double.infinity,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  if (media.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < media.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: i == _index ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? AppColors.cyan
                                    : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: AppText.title),
                    if ((p.summary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(p.summary!, style: AppText.body),
                    ],
                    if ((p.keyFeatures ?? []).isNotEmpty) ...[
                      const SizedBox(height: 14),
                      for (final f in p.keyFeatures!.take(5))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 15,
                                color: AppColors.cyan,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.body,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if ((p.liveUrl ?? '').isNotEmpty)
                          GlowButton(
                            label: 'Live Demo',
                            icon: Icons.language_rounded,
                            onPressed: () => widget.onOpenUrl(p.liveUrl!),
                          ),
                        if ((p.githubUrl ?? '').isNotEmpty)
                          GlowButton(
                            label: 'Repository',
                            icon: Icons.code_rounded,
                            variant: GlowButtonVariant.glass,
                            onPressed: () => widget.onOpenUrl(p.githubUrl!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
