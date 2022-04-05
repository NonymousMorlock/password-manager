// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:yaml/yaml.dart';

/// Class to handle the environment variables
class PassmanEnv {
  static late YamlMap _yaml;

  /// Load the environment variables from the .env file.
  /// Directly calls load from the dotenv package.
  static Future<void> loadEnv(String fileName) async =>
      _yaml = loadYaml(await rootBundle.loadString(fileName));

  /// Returns the root domain from the environment.
  static final String rootDomain = _yaml['ROOT_DOMAIN'] ?? 'vip.ve.atsign.zone';

  /// Returns the root port from the environment.
  static final int rootPort = _yaml['ROOT_PORT'] ?? 64;

  /// Returns the namespace from the environment.
  static final String appNamespace = _yaml['NAMESPACE'] ?? 'passman';

  /// Returns the app api key from the environment.
  static final String? appApiKey = _yaml['API_KEY'];

  /// Returns the app regex from the environment.
  static final String syncRegex = _yaml['SYNC_REGEX'] ?? '.passman';
}
