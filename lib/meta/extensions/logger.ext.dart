// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:at_utils/at_logger.dart';
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

  void _writeToFile(String level, Object message,
          [Object? error, StackTrace? stackTrace]) =>
      File(p.join(logPath,
              'passman_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.log'))
          .writeAsStringSync(
        level.toUpperCase() +
            ' | ${DateTime.now()} | ${logger.name} | $message\n' +
            (error != null ? '$error\n' : '') +
            (stackTrace != null ? '$stackTrace\n' : ''),
        mode: FileMode.append,
      );

  @override
  void shout(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.shout(message, error, stackTrace);
    _writeToFile('SHOUT', message, error, stackTrace);
  }

  @override
  void severe(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.severe(message, error, stackTrace);
    _writeToFile('SEVERE', message, error, stackTrace);
  }

  @override
  void warning(dynamic message, [Object? error, StackTrace? stackTrace]) {
    super.warning(message, error, stackTrace);
    _writeToFile('WARNING', message, null, stackTrace);
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
