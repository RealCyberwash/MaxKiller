import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as lib;

///
enum LogLevel {
  ///
  trace,

  ///
  debug,

  ///
  info,

  ///
  warning,

  ///
  error,
}

///
class LazyLogger {
  ///
  LazyLogger({LogLevel minLevel = LogLevel.debug, bool pretty = true})
    : _minLevel = minLevel {
    final printer = pretty
        ? lib.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: true,
          )
        : lib.SimplePrinter();

    _logger = lib.Logger(printer: printer);
  }

  LogLevel _minLevel;

  late final lib.Logger _logger;

  bool _enabled(LogLevel level) => level.index >= _minLevel.index;

  lib.Level _mapLevel(LogLevel lvl) {
    switch (lvl) {
      case LogLevel.trace:
        return lib.Level.trace;
      case LogLevel.debug:
        return lib.Level.debug;
      case LogLevel.info:
        return lib.Level.info;
      case LogLevel.warning:
        return lib.Level.warning;
      case LogLevel.error:
        return lib.Level.error;
    }
  }

  ///
  void setLevel(LogLevel level) {
    _minLevel = level;
  }

  ///
  void t(Object Function() msg, {Object? error, StackTrace? st}) {
    if (_enabled(LogLevel.trace)) {
      _logger.t(msg(), error: error, stackTrace: st);
    }
  }

  ///
  void d(Object Function() msg, {Object? error, StackTrace? st}) {
    if (_enabled(LogLevel.debug)) {
      _logger.d(msg(), error: error, stackTrace: st);
    }
  }

  ///
  void i(Object Function() msg, {Object? error, StackTrace? st}) {
    if (_enabled(LogLevel.info)) {
      _logger.i(msg(), error: error, stackTrace: st);
    }
  }

  ///
  void w(Object Function() msg, {Object? error, StackTrace? st}) {
    if (_enabled(LogLevel.warning)) {
      _logger.w(msg(), error: error, stackTrace: st);
    }
  }

  ///
  void e(Object Function() msg, {Object? error, StackTrace? stackTrace}) {
    if (_enabled(LogLevel.error)) {
      _logger.e(msg(), error: error, stackTrace: stackTrace);
    }
  }
}

///
final log = LazyLogger(
  minLevel: kReleaseMode ? LogLevel.warning : LogLevel.debug,
);
