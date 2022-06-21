// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

//  Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../core/services/passman.env.dart';
import '../../../core/services/sdk.services.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/set_propic.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/notifiers/theme.notifier.dart';
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/assets.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';
import '../../provider/listeners/user_data.listener.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  State<LoadingDataScreen> createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  final SdkServices _sdk = SdkServices.getInstance();
  final AppLogger _logger = AppLogger('LoadingScreen');
  final LocalAuthentication _authentication = LocalAuthentication();
  @override
  void deactivate() {
    super.deactivate();
  }
  bool _masterImgKeyExists = false,
      _fingerAuthApproved = false,
      _fingerPrint = false,
      _loading = true;
  String _message = 'Loading data...';
  Future<void> _loadData({Function? onFailed}) async {
    try {
      setState(() => _message = 'Setting up your atsign...');
      await AtClientManager.getInstance().setCurrentAtSign(
          context.read<UserData>().currentAtSign,
          PassmanEnv.appNamespace,
          context.read<UserData>().atOnboardingPreference);
      setState(() => _message = 'Syncing data, Please wait...');
      AppServices.syncData();
      while (true) {
        if (context.read<UserData>().syncStatus == SyncStatus.started) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } else {
          break;
        }
      }
      setState(() => _message = 'Applying theme...');
      Map<String, dynamic> themeData =
          await _sdk.getTheme(MediaQuery.of(context).size);
      context.read<AppThemeNotifier>().isDarkTheme = themeData['isDarkTheme'];
      context.read<AppThemeNotifier>().primary =
          Color(int.parse('0x${themeData['themeHex']}'));
      setState(() => _message = 'Fetching your data...');
      context.read<UserData>().isAdmin = await AppServices.isAdmin();
      String? _profilePic = await _sdk.getProPic();
      if (_profilePic != null) {
        context.read<UserData>().currentProfilePic =
            Base2e15.decode(_profilePic);
      } else {
        Uint8List _avatar =
            await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar);
        await showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: false,
          isDismissible: false,
          enableDrag: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          context: _scaffoldKey.currentContext!,
          builder: (_) {
            return SetProPic(_avatar);
          },
        );
      }
      String? _name = await _sdk.getName();
      if (_name != null) {
        context.read<UserData>().name = _name;
      } else {
        context.read<UserData>().name = 'Your Name';
      }
      String? _imgData = await _sdk.checkMasterImageKey();
      if (_imgData != null && _imgData.isNotEmpty) {
        _masterImgKeyExists = true;
        context.read<UserData>().masterImage = Base2e15.decode(_imgData);
      }
      _fingerPrint = await _sdk.checkFingerprint();
      context.read<UserData>().fingerprintAuthEnabled = _fingerPrint;
      if (_fingerPrint) {
        int i = 0;
        while (!_fingerAuthApproved) {
          i += 1;
          if (i == 3) {
            _logger.severe('Fingerprint auth failed more than 3 times');
            exit(-1);
          }
          _fingerAuthApproved = await _authentication.authenticate(
            localizedReason: 'Please authenticate to continue',
          );
        }
        if (_fingerAuthApproved) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
      setState(() => _message = 'Starting monitor...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppServices.startMonitor();
      setState(() => _message = 'Fetching master image...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppServices.getMasterImage();
      setState(() => _message = 'Fetching passwords...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppServices.getPasswords();
      setState(() => _message = 'Fetching images...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppServices.getImages();
      setState(() => _message = 'Fetching cards...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await AppServices.getCards();
      if (context.read<UserData>().isAdmin) {
        setState(() => _message = 'Fetching reports...');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await AppServices.getReports();
        setState(() => _message = 'Fetching admins...');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await AppServices.getAdmins();
      }
      setState(() => _loading = false);
      setState(() => _message = 'Done \u{1F643}');
      Future<void>.delayed(const Duration(milliseconds: 1200), () {
        Navigator.of(context).pushReplacementNamed(_masterImgKeyExists
            ? PageRouteNames.masterPassword
            : PageRouteNames.setMasterPassword);
      });
    } on Exception catch (e, s) {
      _logger.severe('Failed to load data : $e', e, s);
      showToast(_scaffoldKey.currentContext, e.toString(), isError: true);
      if (onFailed != null) {
        onFailed();
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Future<void>.microtask(() async => _loadData(onFailed: _loadData));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_loading) const AdaptiveLoading(),
                if (_loading) vSpacer(30),
                Text(
                  _message,
                  style: _message.startsWith('Done')
                      ? Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 24)
                      : Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: UserDataListener(
              builder: (_, __) => SyncIndicator(size: 15),
            ),
          ),
        ],
      ),
    );
  }
}
