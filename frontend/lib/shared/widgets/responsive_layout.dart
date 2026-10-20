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
