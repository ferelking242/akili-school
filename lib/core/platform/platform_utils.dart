import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

/// Lightweight, web-safe platform detection.
class PlatformUtils {
  PlatformUtils._();

  static bool get isWeb => kIsWeb;

  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  /// True when the device is "large" — desktop or web with wide viewport.
  /// Mobile sized web should still receive the mobile experience.
  static bool isLargeFormFactor(double width) {
    if (isDesktop) return true;
    if (isWeb && width >= 900) return true;
    return false;
  }
}
