// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zxing2/qrcode.dart';

// 🌎 Project imports:
import '../../app/constants/assets.dart';
import '../../app/constants/constants.dart';
import '../../meta/components/toast.dart';
import '../../meta/extensions/logger.ext.dart';
import '../../meta/extensions/string.ext.dart';
import '../../meta/models/qr.model.dart';
import '../../meta/notifiers/new_user.dart';
import '../../meta/notifiers/user_data.dart';
import 'passman.env.dart';
import 'sdk.services.dart';

class AppServices {
  static late final UserData _userData;
  static final AppLogger _logger = AppLogger('AppServices');

  /// [SdkServices] instance
  static final SdkServices sdkServices = SdkServices.getInstance();

  static void init(UserData userData) => _userData = userData;

  /// [OnboardingService] instance
  static final OnboardingService onboardingService =
      OnboardingService.getInstance();

  /// This function will get you a new @sign from the server
  static Future<Map<String, String>> getNewAtSign() async {
    Map<String, String> atSignWithImg = <String, String>{};
    late http.Response response;
    try {
      response = await http.get(
        Uri.https(
          Constants.domain,
          Constants.apiPath + Constants.getFreeAtSign,
        ),
        headers: <String, String>{
          'Authorization': PassmanEnv.appApiKey!,
          'Content-Type': 'application/json',
        },
      );
    } on Exception catch (e) {
      _logger.severe('Error while fetching new @sign: $e');
      return atSignWithImg;
    }
    if (response.statusCode == 200) {
      atSignWithImg['atSign'] = json.decode(response.body)['data']['atsign'];
      atSignWithImg['img'] = Assets.getRandomAvatar();
    } else {
      atSignWithImg['message'] = PassmanEnv.appApiKey == null
          ? 'API key is missing'
          : json.decode(response.body)['message'];
      atSignWithImg['img'] = Assets.error;
    }
    return atSignWithImg;
  }

  /// Use email to register a new @sign
  static Future<bool> registerWithMail(Map<String, String?> requestBody) async {
    late http.Response response;
    String path = Constants.apiPath + Constants.registerUser;
    try {
      response = await http.post(
        Uri.https(Constants.domain, path),
        body: json.encode(requestBody),
        headers: <String, String>{
          'Authorization': PassmanEnv.appApiKey!,
          'Content-Type': 'application/json',
        },
      );
    } on Exception catch (e) {
      _logger.severe('Error while fetching new @sign: $e');
    }
    return response.statusCode == 200;
  }

  /// Validate otp to register your @sign
  static Future<String?> getCRAM(Map<String, dynamic> requestBody) async {
    late http.Response response;
    String path = Constants.apiPath + Constants.validateOTP;
    try {
      response = await http.post(
        Uri.https(Constants.domain, path),
        body: json.encode(requestBody),
        headers: <String, String>{
          'Authorization': PassmanEnv.appApiKey!,
          'Content-Type': 'application/json',
        },
      );
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

  /// Uploads the file to the device.
  /// This function will return the
  static Future<List<PlatformFile>> uploadFile(
          [FileType? fileType, bool? allowMultipleFiles]) async =>
      (await FilePicker.platform.pickFiles(
        type: fileType ?? FileType.any,
        allowMultiple: allowMultipleFiles ?? false,
      ))
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
        ..atSignWithImgData['atSign'] = _qrData.split(':')[0]
        ..atSignWithImgData['img'] =
            (await rootBundle.load(Assets.getRandomAvatar()))
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

  static void refresh() {
    _userData.setSyncStatus = SyncStatus.started;
    sdkServices.atClientManager.syncService.setOnDone(_onSuccessCallback);
    sdkServices.atClientManager.syncService.sync(onDone: _onSuccessCallback);
  }

  static void _onSuccessCallback(SyncResult syncResult) {
    _logger.finer(
        'Sync done : ${DateTime.now()} ${syncResult.toString()} ${syncResult.dataChange}');
    _userData.setSyncStatus = SyncProgress().syncStatus ?? SyncStatus.success;
  }
}
