// 🐦 Flutter imports:

// 📦 Package imports:
import 'package:yaml/yaml.dart';

// 🌎 Project imports:
import '../../meta/extensions/logger.ext.dart';
import 'app.service.dart';

/// Class to handle the environment variables
class PassmanEnv {
  static late YamlMap _yaml;
  static final AppLogger _logger = AppLogger('PassmanEnv');

  /// Load the environment variables from the .env file.
  /// Directly calls load from the dotenv package.
  static Future<void> loadEnv(String fileName) async {
    _logger.finer('Loading environment variables...');
    return _yaml = loadYaml(await AppServices.readLocalfilesAsString(fileName));
  }

  /// Returns the root domain from the environment.
  static final String rootDomain = _yaml['ROOT_DOMAIN'] ?? 'vip.ve.atsign.zone';

  /// Returns the root port from the environment.
  static final int rootPort = _yaml['ROOT_PORT'];

  /// Returns the namespace from the environment.
  static final String appNamespace = _yaml['NAMESPACE'] ?? 'passman';

  /// Returns the app api key from the environment.
  static final String appApiKey =
      _yaml['API_KEY'] ?? '477b-876u-bcez-c42z-6a3d';

  /// Returns the app regex from the environment.
  static final String syncRegex = _yaml['SYNC_REGEX'] ?? '.passman';
}
