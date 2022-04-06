// 🎯 Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_builders.dart';
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
    _logger.finer('Onboarding with @sign: $atSign using atKeys file');
    try {
      dynamic status = await AppServices.onboardingService.authenticate(atSign,
          jsonData: keysData, decryptKey: json.decode(keysData)[atSign]);
      _logger.finer('Onboarding with atKeys file result: $status');
      return status;
    } on Exception catch (e, s) {
      _logger.severe('Error onboarding with @sign: $atSign', e, s);
      return ResponseStatus.authFailed;
    }
  }

  Future<bool> checkUserStatus(String atSign) async {
    List<String>? atSignsList;
    atSignsList =
        await KeyChainManager.getInstance().getAtSignListFromKeychain();
    atSignsList ??= <String>[];
    try {
      AtStatus s = await getAtSignStatus(atSign)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        _logger.warning('Timeout checking @sign status: $atSign');
        throw 'timeOut';
      });
      bool atSignExist = atSignsList.contains(atSign);
      s.serverStatus == ServerStatus.teapot ? atSignExist = false : atSignExist;
      return atSignExist;
    } on Exception catch (e, s) {
      _logger.severe('Error checking user status: $atSign', e, s);
      return false;
    }
  }

  /// Checks if any @sign is onboarded and returns the result.
  Future<bool> checkIfUserAlreadyExist() async {
    try {
      _logger.finer('Checking if user already exist...');
      return (await KeyChainManager.getInstance().getAtsignsWithStatus())
          .values
          .contains(true);
    } on Exception catch (e, s) {
      _logger.severe('Error checking if user already exist', e, s);
      return false;
    }
  }

  /// Check if user is onboarded and returns the result.
  Future<bool> checkIfAtSignExistInDevice(
      String atSign, AtClientPreference preference) async {
    _logger.finer('Checking if @sign exist in device: $atSign');
    bool isExists = await (OnboardingService.getInstance()
          ..setAtsign = atSign
          ..setAtClientPreference = preference)
        .isExistingAtsign(atSign);
    _logger.finer('@sign exist in device: $isExists');
    return isExists;
  }

  /// Returns the current status of the @sign.
  Future<bool> actiavteAtSign(
      String atSign, AtClientPreference preference) async {
    try {
      _logger.finer('Activating @sign: $atSign');
      ResponseStatus _cramAuthResponse = await OnboardingService.getInstance()
          .authenticate(atSign, cramSecret: preference.cramSecret);
      if (_cramAuthResponse.name == 'authSuccess') {
        _logger.finer('CRAM authentication success');
        Map<String, String> keyData = await AppServices.getKeysFileData(atSign);
        ResponseStatus _pkamAuthResponse =
            await onboardWithAtKeys(atSign, jsonEncode(keyData));
        _logger.finer('PKAM authentication result: ${_pkamAuthResponse.name}');
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

  /// Checks if master image exists or not in remote secondary returns the result.
  Future<bool> checkMasterImageKey() async {
    _logger.finer('Getting master image key');
    ScanVerbBuilder verb = ScanVerbBuilder()
      ..auth = true
      ..regex = 'masterpassimg'
      ..sharedBy = currentAtSign;
    String? _data = await atClientManager.atClient
        .getRemoteSecondary()!
        .executeAndParse(verb);
    if (_data == '[]') {
      _logger.warning('No master image key found');
      return false;
    } else {
      _logger.finer('Master image key found: $_data');
      return true;
    }
  }

  /// Fetches the master image key from secondary.
  Future<Uint8List?> getMasterImage() async {
    _logger.finer('Getting master image');
    PassKey _masterImgKey = PassKey(
      key: 'masterpassimg',
      sharedBy: currentAtSign,
    );
    try {
      AtValue value =
          await atClientManager.atClient.get(_masterImgKey.toAtKey());
      return Uint8List.fromList(
          Base2e15.decode(json.decode(value.value)['value']));
    } on Exception catch (e, s) {
      _logger.severe('Error getting master image', e, s);
      return null;
    }
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
      bool putResult =
          await atClientManager.atClient.put(entity.toAtKey(), value);
      AppServices.syncData();
      return putResult;
    } catch (e, s) {
      _logger.severe('Error while putting data', e, s);
      return false;
    }
  }
}
