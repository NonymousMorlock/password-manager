// 🎯 Dart imports:
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zxing2/qrcode.dart';

// 🌎 Project imports:
import '../../app/constants/assets.dart';
import '../../app/constants/constants.dart';
import '../../app/constants/enum.dart';
import '../../app/constants/keys.dart';
import '../../meta/components/toast.dart';
import '../../meta/extensions/logger.ext.dart';
import '../../meta/extensions/plots.ext.dart';
import '../../meta/extensions/string.ext.dart';
import '../../meta/models/freezed/password.model.dart';
import '../../meta/models/freezed/plots.model.dart';
import '../../meta/models/freezed/qr.model.dart';
import '../../meta/models/key.model.dart';
import '../../meta/notifiers/new_user.dart';
import '../../meta/notifiers/user_data.dart';
import 'dec/decode.dart';
import 'dec/decryption.dart';
import 'enc/encryption.dart';
import 'sdk.services.dart';

class AppServices {
  /// Returns the [UserData] instance.
  static late final UserData _userData;

  /// Logger instance
  static final AppLogger _logger = AppLogger('AppServices');

  /// [SdkServices] instance
  static final SdkServices sdkServices = SdkServices.getInstance();

  static void init(UserData userData) => _userData = userData;

  /// [OnboardingService] instance
  static final OnboardingService onboardingService =
      OnboardingService.getInstance();

  /// This function will clear the keychain if the app installed newly again.
  static Future<void> checkFirstRun() async {
    _logger.finer('Checking for keychain entries to clear');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.getBool('first_run') ?? true) {
      _logger.finer('First run detected. Clearing keychain');
      await KeyChainManager.getInstance().clearKeychainEntries();
      await _prefs.setBool('first_run', false);
    }
  }

  /// This function will read local files as string.
  static Future<String> readLocalfilesAsString(String filePath) async =>
      rootBundle.loadString(filePath);

  /// This function will read local files as bytes.
  static Future<Uint8List> readLocalfilesAsBytes(String filePath) async =>
      (await rootBundle.load(filePath)).buffer.asUint8List();

  /// This function will read local files as bytes.
  static Future<Uint8List> readFilesAsBytes(String filePath) async =>
      File(filePath).readAsBytes();

  /// This function will get you a new @sign from the server
  static Future<Map<String, String>> getNewAtSign() async {
    Map<String, String> atSignWithImg = <String, String>{};
    late http.Response response;
    try {
      response = await _apiRequest(Constants.getFreeAtSign);
    } on Exception catch (e) {
      _logger.severe('Error while fetching new @sign: $e');
      return atSignWithImg;
    }
    if (response.statusCode == 200) {
      atSignWithImg['atSign'] = json.decode(response.body)['data']['atsign'];
      atSignWithImg['img'] = Assets.getRandomAvatar();
    } else {
      atSignWithImg['message'] = json.decode(response.body)['message'];
      atSignWithImg['img'] = Assets.error;
    }
    return atSignWithImg;
  }

  /// Use email to register a new @sign
  static Future<bool> registerWithMail(Map<String, String?> requestBody) async {
    late http.Response response;
    try {
      response = await _apiRequest(
          Constants.registerUser, requestBody, ApiRequest.post);
    } on Exception catch (e) {
      _logger.severe('Error while fetching new @sign: $e');
    }
    return response.statusCode == 200;
  }

  /// Validate otp to register your @sign
  static Future<String?> getCRAM(Map<String, dynamic> requestBody) async {
    late http.Response response;
    try {
      response = await _apiRequest(
          Constants.validateOTP, requestBody, ApiRequest.post);
    } on Exception catch (e) {
      _logger.severe('Error while fetching new @sign: $e');
    }
    if (response.statusCode == 200 &&
        json.decode(response.body)['message'].toString().toLowerCase() ==
            'verified') {
      return json.decode(response.body)['cramkey'];
    } else {
      return null;
    }
  }

  /// General api requests
  static Future<http.Response> _apiRequest(String endPoint,
          [Map<String, dynamic>? requestBody,
          ApiRequest request = ApiRequest.get]) async =>
      request.name == 'get'
          ? http.get(
              Uri.https(Constants.domain, Constants.apiPath + endPoint),
              headers: Constants.apiHeaders,
            )
          : http.post(
              Uri.https(Constants.domain, endPoint),
              body: json.encode(requestBody),
              headers: Constants.apiHeaders,
            );

  /// Uploads the file to the device.
  /// This function will return the list of files.
  static Future<List<PlatformFile>> uploadFile(
          [FileType? fileType,
          bool? allowMultipleFiles,
          List<String>? extensions]) async =>
      (await FilePicker.platform.pickFiles(
              type: fileType ?? FileType.any,
              allowMultiple: allowMultipleFiles ?? false,
              allowedExtensions: extensions))
          ?.files ??
      <PlatformFile>[];

  /// Read .atKeys file and return the content as a Map<Strings, String>
  static Future<String> readAtKeysFile(String filePath) async =>
      File(filePath).readAsString();

  /// gets the QR Code data from the image
  static Future<bool> getQRData(BuildContext context, String? filePath) async {
    if (filePath != null) {
      File imgFile = File(filePath);
      if ((await imgFile.length()) < 10) {
        showToast(context, 'Incorrect QR code file', isError: true);
        return false;
      }
      img.Image? _image = img.decodeImage(await imgFile.readAsBytes());

      if (_image == null) {
        showToast(context, 'Error while decoding image', isError: true);
        _logger.severe('Error while decoding image');
        return false;
      }
      late Result _result;
      try {
        LuminanceSource _source = RGBLuminanceSource(
            _image.width,
            _image.height,
            _image.getBytes(format: img.Format.abgr).buffer.asInt32List());
        BinaryBitmap _bitMap = BinaryBitmap(HybridBinarizer(_source));
        _result = QRCodeReader().decode(_bitMap);
      } on Exception catch (e) {
        showToast(context, 'Error while decoding QR code', isError: true);
        _logger.severe('Error while decoding QR code: $e');
        return false;
      }

      String _qrData = _result.text.replaceAll('"', '');
      context.read<UserData>().atOnboardingPreference.cramSecret =
          _qrData.split(':')[1];
      context.read<NewUser>().setQrData = QrModel(
        atSign: _qrData.split(':')[0],
        cramSecret: _qrData.split(':')[1],
      );
      context.read<NewUser>()
        ..newUserData['atSign'] = _qrData.split(':')[0]
        ..newUserData['img'] =
            (await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar()))
                .buffer
                .asUint8List();
      showToast(context, 'QR code decoded successfully');
      _logger.finer('QR code decoded successfully');
      return true;
    } else {
      showToast(context, 'No image selected', isError: true);
      _logger.finer('No image selected');
      return false;
    }
  }

  static Future<Map<String, String>> getKeysFileData(String atSign) async {
    Map<String, String> keysFileData =
        await KeychainUtil.getEncryptedKeys(atSign);
    keysFileData[atSign] = await KeychainUtil.getAESKey(atSign) ?? '';
    return keysFileData;
  }

  /// Function to save keys
  static Future<bool> saveAtKeys(
      String atSign, String keysPath, Size size) async {
    try {
      String _fileName = p.join(keysPath, atSign + '_key.atKeys');
      String _keys = jsonEncode(await getKeysFileData(atSign));
      IOSink _sink = File(_fileName).openWrite();
      _sink.write(_keys);
      await _sink.flush();
      await _sink.close();
      _keys.clear();
      ShareResult shareResult = await Share.shareFilesWithResult(<String>[
        _fileName
      ], sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
      return shareResult.status.name == 'success';
    } on Exception catch (e) {
      _logger.severe('Error while saving keys: $e');
      return false;
    }
  }

  /// Sync the data to the server
  static void syncData() {
    _userData.setSyncStatus = SyncStatus.started;
    sdkServices.atClientManager.syncService.setOnDone(_onSuccessCallback);
    sdkServices.atClientManager.syncService.sync(onDone: _onSuccessCallback);
  }

  /// Function to be called when sync is done
  static void _onSuccessCallback(SyncResult syncResult) {
    _logger.finer(
        '======================= ${syncResult.syncStatus.name} =======================');
    _userData.setSyncStatus = SyncProgress().syncStatus ?? SyncStatus.success;
  }

  /// Fetches the master image key from secondary.
  static Future<void> getMasterImage() async {
    _logger.finer('Getting master image');
    PassKey _masterImgKey = Keys.masterImgKey
      ..sharedBy = sdkServices.currentAtSign;
    try {
      AtValue value = await sdkServices.atClientManager.atClient
          .get(_masterImgKey.toAtKey());
      _userData.masterImage = Uint8List.fromList(
          Base2e15.decode(json.decode(value.value)['value']));
      _logger.finer('Fetched master image successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error getting master image', e, s);
      return;
    }
  }

  /// Fetches the master image key from secondary.
  static Future<void> getProfilePic() async {
    _logger.finer('Fetching profile pic');
    PassKey _masterImgKey = Keys.profilePicKey
      ..sharedBy = sdkServices.currentAtSign;
    try {
      AtValue value = await sdkServices.atClientManager.atClient
          .get(_masterImgKey.toAtKey());
      _userData.currentProfilePic = Uint8List.fromList(
          Base2e15.decode(json.decode(value.value)['value']));
      _logger.finer('Fetched profile picture successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error getting master image', e, s);
      return;
    }
  }

  /// Get Cryptic keys to Encrypt/Decrypt the data
  static Future<String?> getCryptKey() async =>
      (await KeychainUtil.getAESKey(sdkServices.currentAtSign!))
          ?.substring(0, 32);

  /// Validate the plots and return true/false
  static Future<bool> validatePlots(img.Image image, List<Plots> _plots) async {
    _logger.finer('Validating plots');
    try {
      String _msg = '';
      for (Plots pass in _plots) {
        _msg += pass.join();
      }
      log(_msg);
      String? _token = await getCryptKey();
      _msg = Encryption.getInstance().encryptValue(_token!, _msg);
      String? _data = Decode.getInstance()
          .decodeMessageFromImage(image, _token, getRealData: false);
      log(Decryption.getInstance().decryptValue(_token, _data!));
      _logger.finer('Plots validated successfully as ${_msg == _data}');
      return _msg == _data;
    } on Exception catch (e, s) {
      _logger.severe('Error validating plots', e, s);
      return false;
    }
  }

  /// Fetch url favicon
  static Future<Uint8List> getFavicon(String url) async {
    url = url
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .split('/')
        .first;
    http.Response _res;
    try {
      _res = await http.get(Uri.https(Constants.faviconDomain, url));
      _logger.finer('Fetched favicon.');
      if (_res.statusCode == 200 &&
          _res.headers['content-type'] == 'image/png') {
        return _res.bodyBytes;
      } else {
        return Uint8List(0);
      }
    } catch (e, s) {
      _logger.severe('Failed to fetch favicon.', e, s);
      return Uint8List(0);
    }
  }

  static Future<void> getPasswords() async {
    _logger.finer('Fetching passwords');
    try {
      List<Password> _pass = <Password>[];
      List<AtKey> _passwordkeys =
          await sdkServices.getAllKeys(regex: 'password_');
      for (AtKey _key in _passwordkeys) {
        Map<String, dynamic> _value =
            await sdkServices.get(PassKey(key: _key.key));
        Password _password = Password.fromJson(_value);
        _pass.add(_password);
        // await sdkServices.delete(PassKey(key: _key.key));
      }
      _userData.passwords = _pass;
      _logger.finer('Passwords fetched successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error fetching passwords', e, s);
      return;
    }
  }
}
