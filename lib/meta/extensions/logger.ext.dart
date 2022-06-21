// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:at_utils/at_logger.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

// 🌎 Project imports:
import '../../app/constants/global.dart';

// 🐦 Flutter imports:

class AppLogger extends AtSignLogger {
  AppLogger(String name) : super(name) {
    logger.onRecord.listen((LogRecord event) {
      _writeToFile(event.level.name, event.message);
    });
  }
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
}
