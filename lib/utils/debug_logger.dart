import 'package:flutter/foundation.dart';

/// Optimized debug logging utility
/// Produktsiya üçün optimize edilmiş debug log yardımcısı
class DebugLogger {
  /// Log debug information only in debug mode
  /// Debug rejimində yalnız debug məlumatlarını log et
  static void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log error information (always logs)
  /// Xəta məlumatlarını log et (həmişə log edir)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('ERROR: $message');
      if (error != null) debugPrint('Error object: $error');
      if (stackTrace != null) debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Log warning information only in debug mode
  /// Debug rejimində yalnız xəbərdarlıq məlumatlarını log et
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('WARNING: $message');
    }
  }

  /// Log info with emoji prefix for better visibility
  /// Daha yaxşı görünüş üçün emoji prefiksi ilə məlumat log et
  static void info(String message, {String emoji = 'ℹ️'}) {
    if (kDebugMode) {
      debugPrint('$emoji $message');
    }
  }
}