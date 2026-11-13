import 'package:flutter/foundation.dart';

/// Minimal logging facade. Route through here so logging policy
/// (level filtering, crash reporting) can change in one place.
abstract final class AppLog {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
    }
  }

  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[WARN] $message${error != null ? ' — $error' : ''}');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message${error != null ? ' — $error' : ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
