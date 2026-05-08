import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Centralized error reporting utility.
///
/// Wraps Sentry for non-fatal exception capture so providers can
/// report backend failures without crashing the app.
class ErrorReporter {
  ErrorReporter._();

  /// Report a non-fatal exception to Sentry with optional context.
  ///
  /// Safe to call even when Sentry is not configured (DSN empty).
  /// In debug mode, only prints to console.
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    // Always log to console in debug
    debugPrint('[ErrorReporter] ${context ?? 'Error'}: $exception');

    if (kDebugMode) return; // Don't send to Sentry in debug

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        withScope: (scope) {
          if (context != null) {
            scope.setTag('context', context);
          }
          if (extras != null) {
            scope.setContexts('extra_data', extras);
          }
        },
      );
    } catch (e) {
      debugPrint('[ErrorReporter] Failed to send to Sentry: $e');
    }
  }

  /// Report a message-level breadcrumb (e.g., user action tracking).
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (kDebugMode) {
      debugPrint('[ErrorReporter] $message');
      return;
    }

    try {
      await Sentry.captureMessage(message, level: level);
    } catch (e) {
      debugPrint('[ErrorReporter] Failed to send message: $e');
    }
  }

  /// Add a navigation breadcrumb for debugging crash trails.
  static void addBreadcrumb(String message, {String? category}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category ?? 'app',
        timestamp: DateTime.now(),
      ),
    );
  }
}

/// Provider for convenient access in Riverpod-based code.
final errorReporterProvider = Provider<ErrorReporter>((_) {
  return ErrorReporter._();
});
