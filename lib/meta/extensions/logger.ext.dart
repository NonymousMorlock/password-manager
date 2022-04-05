// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:at_utils/at_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

// 🌎 Project imports:
import '../../app/constants/global.dart';

class AppLogger extends AtSignLogger {
  AppLogger(String name) : super(name);
  static const String _rootLevel = 'info';

  static set rootLevel(String? rootLevel) {
    AtSignLogger.root_level = rootLevel?.toLowerCase() ?? _rootLevel;
  }

  void _writeToFile(String level, Object message) => !kDebugMode
      ? File(p.join(logPath,
              'passman_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.log'))
          .writeAsStringSync(
          level.toUpperCase() +
              ' | ${DateTime.now()} | ${logger.name} | $message\n',
          mode: FileMode.append,
        )
      : null;

  @override
  void shout(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.shout(message, error, stackTrace);
    _writeToFile('SHOUT', message);
  }

  @override
  void severe(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.severe(message, error, stackTrace);
    _writeToFile('SEVERE', message);
  }

  @override
  void warning(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.warning(message, error, stackTrace);
    _writeToFile('WARNING', message);
  }

  @override
  void info(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.info(message, error, stackTrace);
    _writeToFile('INFO', message);
  }

  @override
  void finer(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.finer(message, error, stackTrace);
    _writeToFile('FINER', message);
  }

  @override
  void finest(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.finest(message, error, stackTrace);
    _writeToFile('FINEST', message);
  }
}
