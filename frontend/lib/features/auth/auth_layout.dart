import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Layout auth FolioSpace: panel brand kiri (desktop), form kanan.
class AuthLayout extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;
  final String sideTitle;
  final String sideSubtitle;

  const AuthLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
    this.sideTitle = 'Bangun personal brand yang menonjol.',
    this.sideSubtitle =
        'Satu tempat untuk portofolio, proyek, skill, dan pesan dari klien.',
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (wide)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(36),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF14142B),
                                  Color(0xFF3B34B8),
                                  AppColors.indigo,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('F',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              color: AppColors.ink)),
                                    ),
                                    const SizedBox(width: 10),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('FolioSpace',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17)),
                                        Text('Portfolio builder',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(sideTitle,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2)),
                                const SizedBox(height: 12),
                                Text(sideSubtitle,
                                    style: const TextStyle(
                                        color: Colors.white70)),
                                const SizedBox(height: 24),
                                const Wrap(
                                  spacing: 8,
                                  children: [
                                    _SideChip('Portofolio publik'),
                                    _SideChip('Kelola proyek'),
                                    _SideChip('Inbox klien'),
                                  ],
                                ),
                                const Spacer(),
                                const Text(
                                    '© 2026 FolioSpace',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(wide ? 40 : 24),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(eyebrow,
                                  style: const TextStyle(
                                      color: AppColors.indigo,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(title,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(subtitle,
                                  style: const TextStyle(
                                      color: AppColors.muted)),
                              const SizedBox(height: 24),
                              form,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideChip extends StatelessWidget {
  final String label;
  const _SideChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 12)),
    );
  }
}
