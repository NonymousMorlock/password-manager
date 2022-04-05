// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/response_status.dart';
import 'package:at_server_status/at_server_status.dart';

// 🌎 Project imports:
import '../../meta/extensions/logger.ext.dart';
import '../../meta/models/key.model.dart';
import 'app.service.dart';
import 'passman.env.dart';

class SdkServices {
  final AppLogger _logger = AppLogger('SDK services');

  /// singleton with getInstance()
  static final SdkServices _singleton = SdkServices._internal();

  SdkServices._internal();
  factory SdkServices.getInstance() {
    return _singleton;
  }

  AtClientManager atClientManager = AtClientManager.getInstance();

  /// Get @sign status
  Future<AtStatus> getAtSignStatus(String atSign) async => AtStatusImpl(
        rootUrl: PassmanEnv.rootDomain,
      ).get(atSign);

  /// Onboard the app with an @sign and return the response as bool
  Future<ResponseStatus> onboardWithAtKeys(
      String atSign, String keysData) async {
    dynamic status = await AppServices.onboardingService.authenticate(atSign,
        jsonData: keysData, decryptKey: json.decode(keysData)[atSign]);
    status = status as ResponseStatus;
    return status;
  }

  Future<bool> checkUserStatus(String atSign) async {
    List<String>? atSignsList;
    atSignsList =
        await KeyChainManager.getInstance().getAtSignListFromKeychain();
    atSignsList ??= <String>[];
    AtStatus s = await getAtSignStatus(atSign)
        .timeout(const Duration(seconds: 30), onTimeout: () => throw 'timeOut');
    bool atSignExist = atSignsList.contains(atSign);
    s.serverStatus == ServerStatus.teapot ? atSignExist = false : atSignExist;
    return atSignExist;
  }

  /// Checks if any @sign is onboarded and returns the result.
  Future<bool> checkIfUserAlreadyExist() async =>
      (await KeyChainManager.getInstance().getAtsignsWithStatus())
          .values
          .contains(true);

  /// Check if user is onboarded and returns the result.
  Future<bool> checkIfAtSignExistInDevice(
          String atSign, AtClientPreference preference) async =>
      (OnboardingService.getInstance()
            ..setAtsign = atSign
            ..setAtClientPreference = preference)
          .isExistingAtsign(atSign);

  /// Returns the current status of the @sign.
  Future<bool> actiavteAtSign(
      String atSign, AtClientPreference preference) async {
    try {
      ResponseStatus _cramAuthResponse = await OnboardingService.getInstance()
          .authenticate(atSign, cramSecret: preference.cramSecret);
      if (_cramAuthResponse.name == 'authSuccess') {
        Map<String, String> keyData = await AppServices.getKeysFileData(atSign);
        ResponseStatus _pkamAuthResponse =
            await onboardWithAtKeys(atSign, jsonEncode(keyData));
        _pkamAuthResponse.name == 'authSuccess'
            ? await AtClientManager.getInstance()
                .setCurrentAtSign(atSign, PassmanEnv.appNamespace, preference)
            : null;
        return _pkamAuthResponse.name == 'authSuccess';
      } else {
        return false;
      }
    } on Exception catch (e) {
      Exception('Error while activating @sign : ' + e.toString());
      return false;
    }
  }

  String? get currentAtSign => atClientManager.atClient.getCurrentAtSign();

  Future<String?> getProPic() async {
    List<AtKey> list = await atClientManager.atClient
        .getAtKeys(regex: 'profilepic', sharedBy: currentAtSign);
    for (AtKey key in list) {
      if (key.key == 'profilepic' && key.namespace == PassmanEnv.appNamespace) {
        AtValue img = await atClientManager.atClient.get(key);
        return json.decode(img.value)['value'];
      }
    }
    return null;
  }

  // --------------------- //
  //    CRUD operations    //
  // --------------------- //

  Future<bool> put(PassKey entity) async {
    try {
      //set value
      dynamic value = entity.isBinary == false
          ? jsonEncode(entity.value?.toJson())
          : entity.value?.value;

      return atClientManager.atClient.put(entity.toAtKey(), value);
    } catch (e) {
      _logger.severe('Error while putting data: $e');
      return false;
    }
  }
}
