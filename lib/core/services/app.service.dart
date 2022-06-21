// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

//  Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:file_picker/file_picker.dart';
// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
import '../../meta/models/freezed/admin.model.dart';
import '../../meta/models/freezed/card.model.dart';
import '../../meta/models/freezed/image.model.dart';
import '../../meta/models/freezed/password.model.dart';
import '../../meta/models/freezed/plots.model.dart';
import '../../meta/models/freezed/qr.model.dart';
import '../../meta/models/freezed/report.model.dart';
import '../../meta/models/key.model.dart';
import '../../meta/notifiers/new_user.notifier.dart';
import '../../meta/notifiers/user_data.notifier.dart';
import 'dec/decode.dart';
import 'dec/decryption.dart';
import 'enc/encryption.dart';
import 'passman.env.dart';
import 'sdk.services.dart';

class AppServices {
  static late FlutterLocalNotificationsPlugin _notificationsPlugin;

  /// Returns the [UserData] instance.
  static late final UserData _userData;

  /// Logger instance
  static final AppLogger _logger = AppLogger('AppServices');

  /// [SdkServices] instance
  static final SdkServices sdkServices = SdkServices.getInstance();

  static Future<void> init(
      UserData userData, Function onNotificationTap) async {
    try {
      _userData = userData;
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: false,
              badge: true,
              sound: true,
            );
      }
      await _notificationsPlugin.initialize(
        InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification:
                (int id, String? title, String? body, String? payload) async {
              _logger
                  .finer('id $id, title $title, body $body, payload $payload');
              onNotificationTap();
            },
          ),
          macOS: const MacOSInitializationSettings(
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
        onSelectNotification: (String? payload) async {
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
        },
      );
      _logger.finer('initialiazed notification service');
    } on Exception catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      _logger.severe('failed to initialize notification service : $e', e, s);
    }
  }

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

  /// Check for the list of permissions.
  static Future<bool> checkPermission(List<Permission> permissions) async {
    int _permissionsCount = permissions.length;
    while (_permissionsCount == 0) {
      for (Permission permission in permissions) {
        if (await permission.status != PermissionStatus.granted) {
          await permission.request();
          _permissionsCount--;
        } else {
          _permissionsCount--;
        }
      }
    }
    return _permissionsCount == 0;
  }

  /// This function determines the CC type based on the cardPatterns
  static CreditCardType detectCCType(String ccNumStr) {
    CreditCardType cardType = CreditCardType.unknown;
    ccNumStr = ccNumStr.replaceAll(Constants.whiteSpace, '');

    if (ccNumStr.isEmpty) {
      return cardType;
    }

    // Check that only numerics are in the string
    if (Constants.nonNumeric.hasMatch(ccNumStr)) {
      return cardType;
    }

    Constants.cardNumPatterns.forEach(
      (CreditCardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr = ccNumStr;
          int rangeLen = patternRange[0].length;
          // Trim the CC number str to match the pattern prefix length
          if (rangeLen < ccNumStr.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // CC num is in the pattern range.
            // Because Strings don't have '>=' type operators
            int ccPrefixAsInt = int.parse(ccPatternStr);
            int startPatternPrefixAsInt = int.parse(patternRange[0]);
            int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the CC prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );
    return cardType;
  }

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
      atSignWithImg['img'] = Assets.getRandomAvatar;
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
    _logger.finer(
        'Register with mail response status code: ${response.statusCode}');
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
              Uri.https(Constants.domain, Constants.apiPath + endPoint),
              body: json.encode(requestBody),
              headers: Constants.apiHeaders,
            );

  /// Uploads the file to the device.
  /// This function will return the list of files.
  static Future<Set<PlatformFile>> uploadFile(
          [FileType? fileType,
          bool? allowMultipleFiles,
          List<String>? extensions]) async =>
      (await FilePicker.platform.pickFiles(
              type: fileType ?? FileType.any,
              allowMultiple: allowMultipleFiles ?? false,
              allowedExtensions: extensions))
          ?.files
          .toSet() ??
      <PlatformFile>{};

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
            (await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar))
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
      return shareResult.status == ShareResultStatus.success;
    } on Exception catch (e) {
      _logger.severe('Error while saving keys: $e');
      return false;
    }
  }

  /// Delete AtKeys file from download path
  static Future<bool> deleteAtKeysFiles(String dirPath) async {
    try {
      for (FileSystemEntity atKeysFile in Directory(dirPath).listSync()) {
        if (atKeysFile.path.endsWith('.atkeys')) {
          await atKeysFile.delete();
        }
      }
      return true;
    } on FileSystemException catch (e) {
      _logger.severe(e.message);
      return false;
    }
  }

  /// Function to logout the user
  static Future<bool> logout() async {
    AtClientPreference? _pref =
        sdkServices.atClientManager.atClient.getPreferences();
    if (_pref != null) {
      try {
        _logger.finer('Stopping app notification monitor');
        sdkServices.atClientManager.notificationService.stopAllSubscriptions();
        await KeyChainManager.getInstance().clearKeychainEntries();
        return true;
      } on Exception catch (e, s) {
        _logger.severe('Error while logging out: $e', e, s);
        return false;
      }
    } else {
      _logger.severe('Error while logging out: AtClient preference is null');
      return false;
    }
  }

  // startMonitor needs to be called at the beginning of session
  static Future<void> startMonitor() async {
    _logger.finer('Starting app notification monitor');
    sdkServices.atClientManager.notificationService
        .subscribe(regex: PassmanEnv.syncRegex)
        .listen((AtNotification monitorNotification) async {
      try {
        _logger.finer('Listening to notification: ${monitorNotification.id}');
        if (!(await sdkServices.atClientManager.syncService.isInSync())) {
          syncData();
        }
        await _listenToNotifications(monitorNotification);
        await getReports();
      } catch (e) {
        _logger.severe(e.toString());
      }
    });
  }

  static Future<void> _listenToNotifications(
      AtNotification monitorNotification) async {
    _logger.finer('Listening to notification: ${monitorNotification.id}');
    await _showNotification(monitorNotification);
  }

  static Future<void> _showNotification(AtNotification atNotification) async {
    _logger.finer('inside show notification...');
    NotificationDetails platformChannelSpecifics = const NotificationDetails(
      android: AndroidNotificationDetails('CHANNEL_ID', 'CHANNEL_NAME',
          channelDescription: 'CHANNEL_DESCRIPTION',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false),
      iOS: IOSNotificationDetails(),
    );

    if (atNotification.key.contains('report')) {
      await _notificationsPlugin.show(
          0,
          'Report',
          atNotification.from + ' submitted feedback.',
          platformChannelSpecifics,
          payload: jsonEncode(atNotification.toJson()));
    }
  }

  /// Sync the data to the server
  static void syncData([Function? onSyncDone]) {
    Future<void> _onSyncData(SyncResult synRes) async {
      await _onSuccessCallback(synRes);
      if (onSyncDone != null) {
        onSyncDone();
      }
      if (_userData.isAdmin) await AppServices.getReports();
    }

    _userData.setSyncStatus = SyncStatus.started;
    sdkServices.atClientManager.syncService.setOnDone(_onSyncData);
    sdkServices.atClientManager.syncService.sync(onDone: _onSyncData);
  }

  /// Function to be called when sync is done
  static Future<void> _onSuccessCallback(SyncResult syncResult) async {
    _logger.finer(
        '======================= ${syncResult.syncStatus.name} =======================');
    _userData.setSyncStatus = SyncProgress().syncStatus ?? SyncStatus.success;
    await HapticFeedback.lightImpact();
  }

  /// Fetches the master image key from secondary.
  static Future<void> getMasterImage() async {
    _logger.finer('Getting master image');
    List<AtKey> _keys = await sdkServices.atClientManager.atClient
        .getAtKeys(regex: Keys.masterImgKey.key);
    try {
      for (AtKey _key in _keys) {
        AtValue value = await sdkServices.atClientManager.atClient.get(_key);
        _userData.masterImage = Uint8List.fromList(
            Base2e15.decode(json.decode(value.value)['value']));
      }
      _logger.finer('Fetched master image successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error getting master image', e, s);
      return;
    }
  }

  static Future<bool> isAdmin() async {
    _logger.finer('Checking if user is admin...');
    bool _isAdmin;
    await getAdmins();
    for (Admin element in _userData.admins) {
      if (element.atSign.replaceFirst('@', '') ==
          sdkServices.currentAtSign!.replaceFirst('@', '')) {
        _isAdmin = true;
        await sdkServices.put(Keys.adminKey..value!.value = _isAdmin);
        break;
      }
    }
    _isAdmin = await sdkServices.get(Keys.adminKey) ?? false;
    _isAdmin
        ? _logger.warning('User is admin')
        : _logger.finer('User is not admin');
    return _isAdmin;
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
            await sdkServices.get(PassKey.fromAtKey(_key));
        Password _password = Password.fromJson(_value);
        _pass.add(_password);
      }
      _userData.passwords = _pass;
      _logger.finer('Passwords fetched successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error fetching passwords', e, s);
      return;
    }
  }

  static Future<void> getCards() async {
    _logger.finer('Fetching Cards');
    try {
      List<CardModel> _cards = <CardModel>[];
      List<AtKey> _cardkeys = await sdkServices.getAllKeys(regex: 'cards_');
      for (AtKey _key in _cardkeys) {
        Map<String, dynamic>? _value =
            await sdkServices.get(PassKey.fromAtKey(_key));
        if (_value != null) {
          CardModel _card = CardModel.fromJson(_value);
          _cards.add(_card);
        }
        // bool isDelete = await sdkServices.delete(PassKey.fromAtKey(_key));
        // print(isDelete);
      }
      _cardkeys.clear();
      _userData.cards = _cards;
      _logger.finer('Passwords fetched successfully');
    } on Exception catch (e, s) {
      _logger.severe('Error fetching passwords', e, s);
      return;
    }
  }

  static Future<void> getImages() async {
    _logger.finer('Fetching Images');
    try {
      List<Images> _images = <Images>[];
      List<AtKey> _imagekeys = await sdkServices.getAllKeys(regex: 'images_');
      for (AtKey _key in _imagekeys) {
        Map<String, dynamic>? _value =
            await sdkServices.get(PassKey.fromAtKey(_key));
        if (_value != null) {
          Images _image = Images.fromJson(_value);
          _images.add(_image);
        }
        // bool isDelete = await sdkServices.delete(_key.key!);
        // print(isDelete);
      }
      _imagekeys.clear();
      _images.sort((Images a, Images b) => b.createdAt.compareTo(a.createdAt));
      _userData.images = _images;
    } on Exception catch (e, s) {
      _logger.severe('Error fetching images', e, s);
      return;
    }
  }

  static Future<void> getReports() async {
    _logger.finer('Fetching Reports');
    try {
      List<Report> _reports = <Report>[];
      List<AtKey> _reportKeys = await sdkServices.getAllKeys(regex: 'report_');
      for (AtKey _key in _reportKeys) {
        // if (!_key.metadata!.isCached) {
        //   _userData.reports = _reports;
        //   return;
        // }
        dynamic _value = await sdkServices.get(PassKey.fromAtKey(_key));
        if (_value != null) {
          Report _report = Report.fromJson(_value);
          _reports.add(_report);
        }
      }
      _reports.sort((Report a, Report b) => b.createdAt.compareTo(a.createdAt));
      _reportKeys.clear();
      _userData.reports = _reports;
    } on Exception catch (e, s) {
      _logger.severe('Error fetching reports', e, s);
      return;
    }
  }

  /// Save the reports - (Only for admins)
  static Future<bool> saveReports(Size size) async {
    String _logsPath =
        p.join((await getApplicationSupportDirectory()).path, 'logs');
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    ShareResult shareResult = await Share.shareFilesWithResult(
        <String>[p.join(_logsPath, 'passman_$date.log')],
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2));
    bool _saved = shareResult.status == ShareResultStatus.success;
    return _saved;
  }

  static Future<void> getAdmins() async {
    _logger.finer('Fetching Admins');
    http.Response _res = await http.get(
        Uri.https(Constants.adminHost, Constants.adminPath),
        headers: Constants.adminHeader);
    if (_res.statusCode == 200) {
      Map<String, dynamic> _jsonData = jsonDecode(_res.body);
      List<dynamic> _admins = _jsonData['admins'];
      List<dynamic> _superAdmins = _jsonData['superAdmins'];
      List<Admin> _adminList = <Admin>[];
      for (dynamic _admin in _admins) {
        _admin['isSuperAdmin'] = false;
        Admin _adminModel = Admin.fromJson(_admin);
        _adminList.removeWhere((Admin _admin) => _admin.id == _adminModel.id);
        _adminList.add(_adminModel);
      }
      for (dynamic _superAdmin in _superAdmins) {
        _superAdmin['isSuperAdmin'] = true;
        Admin _adminModel = Admin.fromJson(_superAdmin);
        _adminList.removeWhere((Admin _admin) => _admin.id == _adminModel.id);
        _adminList.add(_adminModel);
      }
      _userData.admins = _adminList;
    }
  }
}

// class MySyncProgressListener extends SyncProgressListener {
//   final BuildContext context;
//   MySyncProgressListener(this.context);
//   @override
//   Future<void> onSyncProgressEvent(SyncProgress syncProgress) async {
//     if (syncProgress.isInitialSync) {
//       context.read<UserData>().isInitialSync = syncProgress.isInitialSync;
//       print('------------------ Starting while loop ------------------');
//       await whileLoop(syncProgress.isInitialSync);
//     } else {
//       AppLogger('MySyncProgressListener').finer('Delta sync in progress');
//     }
//   }
// }

// Future<void> whileLoop(bool isInitialSync) async {
//   int i = 0;
//   while (true) {
//     if (!isInitialSync) {
//       await AppServices.sdkServices.put(PassKey()
//         ..key = 'testing_key'
//         ..value!.value = i);
//       await Future<void>.delayed(const Duration(milliseconds: 500));
//       print('Updated value : $i');
//       i += 1;
//     }
//   }
// }
