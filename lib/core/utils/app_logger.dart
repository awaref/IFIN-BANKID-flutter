import 'package:flutter/foundation.dart';

class AppLogger {
  /// Logs a message only in debug mode.
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Logs an error message only in debug mode.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint("❌ ERROR: $message");
      if (error != null) debugPrint(error.toString());
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }
  }

  /// Logs a warning message only in debug mode.
  static void warn(String message) {
    if (kDebugMode) {
      debugPrint("⚠️ WARNING: $message");
    }
  }
}
