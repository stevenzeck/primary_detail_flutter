import 'package:flutter/foundation.dart';

/// Utility class for platform detection.
class PlatformUtils {
  /// Returns true if the current platform is iOS or macOS.
  static bool get isApple {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }
}
