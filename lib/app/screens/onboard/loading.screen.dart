import 'dart:io';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:at_base2e15/at_base2e15.dart';
import '../../../core/services/app.service.dart';
import '../../../core/services/passman.env.dart';
import '../../../core/services/sdk.services.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/set_propic.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/notifiers/theme.notifier.dart';
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/assets.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';

class LoadingDataScreen extends StatefulWidget {
  const LoadingDataScreen({Key? key}) : super(key: key);

  @override
  State<LoadingDataScreen> createState() => _LoadingDataScreenState();
}

class _LoadingDataScreenState extends State<LoadingDataScreen> {
  final SdkServices _sdk = SdkServices.getInstance();
  final AppLogger _logger = AppLogger('LoadingScreen');
  final LocalAuthentication _authentication = LocalAuthentication();
  bool _masterImgKeyExists = false,
      _fingerAuthApproved = false,
      _fingerPrint = false,
      _loading = true;
  String _message = 'Loading data...';
  Future<void> _loadData() async {
    setState(() => _message = 'Setting up your atsign...');
    await AtClientManager.getInstance().setCurrentAtSign(
        context.read<UserData>().currentAtSign,
        PassmanEnv.appNamespace,
        context.read<UserData>().atOnboardingPreference);
    setState(() => _message = 'Applying theme...');
    Map<String, dynamic> themeData = await _sdk.getTheme();
    context.read<AppThemeNotifier>().isDarkTheme = themeData['isDarkTheme'];
    context.read<AppThemeNotifier>().primary =
        Color(int.parse('0x${themeData['themeHex']}'));
    AppServices.syncData();
    while (
        AppServices.sdkServices.atClientManager.syncService.isSyncInProgress) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    setState(() => _message = 'Fetching your data...');
    context.read<UserData>().isAdmin = await _sdk.isAdmin();
    String? _profilePic = await _sdk.getProPic();
    if (_profilePic != null) {
      context.read<UserData>().currentProfilePic = Base2e15.decode(_profilePic);
    } else {
      Uint8List _avatar =
          await AppServices.readLocalfilesAsBytes(Assets.getRandomAvatar());
      await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        context: context,
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
    _masterImgKeyExists = await _sdk.checkMasterImageKey();
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
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
    setState(() => _message = 'Starting monitor...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await AppServices.startMonitor();
    setState(() => _message = 'Fetching passwords...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await AppServices.getPasswords();
    setState(() => _message = 'Fetching images...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await AppServices.getImages();
    setState(() => _message = 'Fetching cards...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await AppServices.getCards();
    setState(() => _message = 'Fetching reports...');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await AppServices.getReports();
    setState(() => _loading = false);
    setState(() => _message = 'Done \u{1F643}');
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      Navigator.of(context).pushReplacementNamed(_masterImgKeyExists
          ? PageRouteNames.masterPassword
          : PageRouteNames.setMasterPassword);
    });
  }

  @override
  void initState() {
    Future<void>.microtask(() async => _loadData());
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_loading) const AdaptiveLoading(),
            if (_loading) vSpacer(30),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
