import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Лёгкий логгер. В release-сборке ничего не пишет —
/// это исключает утечку тел ответов (телефоны, балансы, токены) в логи.
class AppLogger {
  static void d(String message) {
    if (kDebugMode) {
      developer.log(message, name: 'app');
    }
  }

  static void e(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      developer.log(message, name: 'app', error: error, stackTrace: stack);
    }
  }
}
