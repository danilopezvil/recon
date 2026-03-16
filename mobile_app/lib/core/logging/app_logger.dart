import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static bool get _enabled =>
      kDebugMode || const bool.fromEnvironment('ENABLE_TECH_LOGS', defaultValue: false);

  static void info(String message, {String tag = 'APP'}) {
    if (!_enabled) return;
    developer.log(message, name: tag, level: 800);
  }

  static void warn(String message, {String tag = 'APP'}) {
    if (!_enabled) return;
    developer.log(message, name: tag, level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String tag = 'APP'}) {
    if (!_enabled) return;
    developer.log(message, name: tag, level: 1000, error: error, stackTrace: stackTrace);
  }

  static String redact(String? value, {int keep = 4}) {
    if (value == null || value.isEmpty) return '<empty>';
    if (value.length <= keep) return '***';
    return '${value.substring(0, keep)}***';
  }
}
