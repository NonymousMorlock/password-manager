// 🌎 Project imports:
import '../../core/services/passman.env.dart';

class Constants {
  /// Doamin for the API
  static String get domain => PassmanEnv.rootDomain.split('.')[2] == 'wtf'
      ? 'my.atsign.wtf'
      : 'my.atsign.com';

  /// API version path
  static const String apiPath = '/api/app/v2/';

  /// End point for getting a new atsign
  static const String getFreeAtSign = 'get-free-atsign';

  /// End point for registering a new atsign to an user
  static const String registerUser = 'register-person';

  /// End point for validating a new atsign to an user
  static const String validateOTP = 'validate-person';

  /// @sign regex pattern
  static const String atSignPattern =
      '[a-zA-Z0-9_]|\u00a9|\u00af|[\u2155-\u2900]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]';
}
