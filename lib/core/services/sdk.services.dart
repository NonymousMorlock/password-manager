// 🎯 Dart imports:
import 'dart:convert';

// 📦 Package imports:
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

  Future<bool> isAdmin() async {
    _logger.finer('Checking if user is admin...');
    ScanVerbBuilder verb = ScanVerbBuilder()
      ..auth = true
      ..regex = 'admin'
      ..sharedBy = currentAtSign;
    String? _data = await atClientManager.atClient
        .getRemoteSecondary()!
        .executeAndParse(verb);
    if (_data == '[]') {
      _logger.warning('User is not admin');
      return false;
    } else {
      bool _isAdmin = await get(PassKey(key: 'admin'));
      _isAdmin
          ? _logger.warning('User is admin')
          : _logger.finer('User is not admin');
      return _isAdmin;
    }
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

  /// Checks if master image exists or not in remote secondary returns the result.
  Future<bool> checkFingerprint() async {
    _logger.finer('Checking fingerprint');
    ScanVerbBuilder verb = ScanVerbBuilder()
      ..auth = true
      ..regex = 'fingerprint'
      ..sharedBy = currentAtSign;
    String? _data = await atClientManager.atClient
        .getRemoteSecondary()!
        .executeAndParse(verb);
    if (_data == '[]') {
      _logger.warning('No fingerprint key found');
      return false;
    } else {
      _logger.finer('Fingerprint key found: $_data');
      bool _enabled = await get(
        PassKey.fromAtKey((await getAllKeys(regex: 'fingerprint')).first),
      );
      _logger.finer('Fingerprint enabled : $_enabled');
      return _enabled;
    }
  }

  Future<String?> getName() async {
    _logger.finer('Getting name');
    ScanVerbBuilder verb = ScanVerbBuilder()
      ..auth = true
      ..regex = 'name'
      ..sharedBy = currentAtSign;
    String? _data = await atClientManager.atClient
        .getRemoteSecondary()!
        .executeAndParse(verb);
    if (_data == '[]') {
      _logger.warning('No name key found');
      return null;
    } else {
      _logger.finer('Name key found: $_data');
      String name = await get(
        PassKey.fromAtKey((await getAllKeys(regex: 'name')).first),
      );
      return name;
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
      if (putResult) AppServices.syncData();
      return putResult;
    } catch (e, s) {
      _logger.severe('Error while putting data', e, s);
      return false;
    }
  }

  /// Get the value of the key.
  Future<dynamic> get(PassKey entity) async {
    try {
      AtValue _value = await atClientManager.atClient.get(entity.toAtKey());
      return jsonDecode(_value.value)['value'];
    } on KeyNotFoundException catch (e, s) {
      _logger.severe('Key not found with message ${e.message}', e, s);
      return null;
    } on Exception catch (e, s) {
      _logger.severe('Error while getting data', e, s);
      return null;
    }
  }

  Future<bool> delete(String key) async {
    bool _keyDeleted = false;
    try {
      List<AtKey> a = await getAllKeys(regex: key);
      if (a.length > 1) {
        _logger
            .severe('Looks like you have more that one key with the keyname');
        return false;
      }
      for (AtKey k in a) {
        _keyDeleted = await atClientManager.atClient.delete(k);
      }
      // bool deleteResult =
      //     await atClientManager.atClient.delete(entity.toAtKey());
      if (_keyDeleted) {
        _logger.finer('$key deleted successfully');
        AppServices.syncData();
      }
      return _keyDeleted;
    } on KeyNotFoundException catch (e, s) {
      _logger.severe('${e.message} to delete it.', e, s);
      return false;
    } on Exception catch (e, s) {
      _logger.severe('Error while deleting data', e, s);
      return false;
    }
  }

  Future<List<AtKey>> getAllKeys({
    String? regex,
    String? sharedBy,
    String? sharedWith,
  }) async {
    try {
      List<AtKey> result = await atClientManager.atClient
          .getAtKeys(regex: regex, sharedBy: sharedBy, sharedWith: sharedWith);
      return result;
    } on Exception catch (e, s) {
      _logger.severe('Error while fetching keys', e, s);
      return <AtKey>[];
    }
  }
}
