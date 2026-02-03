import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const String _appName = 'FinanceTracker';

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _log(
        level: LogLevel.debug,
        message: message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(
      level: LogLevel.info,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(
      level: LogLevel.critical,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log({
    required LogLevel level,
    required String message,
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final logMessage = '$tagPrefix$message';
    final errorSuffix = error != null ? '\nError: $error' : '';
    final stackSuffix = stackTrace != null ? '\nStackTrace:\n$stackTrace' : '';

    final fullMessage = '$logMessage$errorSuffix$stackSuffix';

    developer.log(
      fullMessage,
      time: DateTime.now(),
      level: level.value,
      name: '$_appName.${level.name}',
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      final coloredMessage = '${level.emoji} ${level.color}[$_appName] $fullMessage\x1B[0m';
      debugPrint(coloredMessage);
    }
  }
}

enum LogLevel {
  debug(0, '🔍', '\x1B[37m'),
  info(800, 'ℹ️', '\x1B[36m'),
  warning(900, '⚠️', '\x1B[33m'),
  error(1000, '❌', '\x1B[31m'),
  critical(1200, '🔥', '\x1B[35m');

  const LogLevel(this.value, this.emoji, this.color);

  final int value;
  final String emoji;
  final String color;
}
