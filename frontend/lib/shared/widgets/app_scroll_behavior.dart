import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Scroll natural di web: wheel, trackpad, dan drag mouse semuanya bekerja.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
