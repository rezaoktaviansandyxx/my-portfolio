import 'package:flutter/material.dart';

/// Breakpoint tunggal aplikasi: di atas 900px dianggap desktop.
const double kDesktopBreakpoint = 900;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) => c.maxWidth > kDesktopBreakpoint ? desktop : mobile,
    );
  }
}

/// Varian builder untuk kasus yang butuh flag di dalam satu sub-tree.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isDesktop) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) => builder(ctx, c.maxWidth > kDesktopBreakpoint),
    );
  }
}
