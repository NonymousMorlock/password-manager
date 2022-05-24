// 🐦 Flutter imports:

// 📦 Package imports:

// 📦 Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 🌎 Project imports:
import '../../meta/extensions/logger.ext.dart';

/// Class to handle the environment variables
class PassmanEnv {
  static final AppLogger _logger = AppLogger('PassmanEnv');

  /// Load the environment variables from the .env file.
  /// Directly calls load from the dotenv package.
  static Future<void> loadEnv(String fileName) async {
    _logger.finer('Loading environment variables...');
    return dotenv.load();
    // return _yaml = loadYaml(await AppServices.readLocalfilesAsString(fileName));
  }

  /// Returns the root domain from the environment.
  static final String rootDomain =
      dotenv.env['ROOT_DOMAIN'] ?? 'vip.ve.atsign.zone';

  /// Returns the root port from the environment.
  static final int rootPort =
      int.parse(dotenv.env['ROOT_PORT'] ?? 64.toString());

  /// Returns the namespace from the environment.
  static final String appNamespace = dotenv.env['NAMESPACE'] ?? 'passman';

  /// Returns the app api key from the environment.
  static final String appApiKey =
      dotenv.env['API_KEY'] ?? '477b-876u-bcez-c42z-6a3d';

  /// Returns the app regex from the environment.
  static final String syncRegex = dotenv.env['SYNC_REGEX'] ?? '.passman';

  /// Returns the app reporting @sign from the environment.
  static final String reportAtsign = dotenv.env['REPORT_ATSIGN'] ?? '@';

  /// Returns the app api key from the environment.
  static final String adminApiKey =
      dotenv.env['ADMIN_KEY']!;
}
