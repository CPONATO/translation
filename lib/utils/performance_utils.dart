import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceUtils {
  static Future<T> withPerformanceLogging<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      if (kDebugMode) {
        print('$operationName completed in ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      stopwatch.stop();

      if (kDebugMode) {
        print(
          '$operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e',
        );
      }

      rethrow;
    }
  }

  static Future<void> delayExecution(Duration delay) {
    return Future.delayed(delay);
  }

  static void throttle(
    String key,
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _throttleTimers[key]?.cancel();
    _throttleTimers[key] = Timer(duration, callback);
  }

  static final Map<String, Timer> _throttleTimers = {};
}
