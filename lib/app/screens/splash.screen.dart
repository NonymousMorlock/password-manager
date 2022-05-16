// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../core/services/app.service.dart';
import '../../core/services/passman.env.dart';
import '../../core/services/sdk.services.dart';
import '../../meta/components/toast.dart';
import '../../meta/extensions/logger.ext.dart';
import '../../meta/notifiers/user_data.dart';
import '../constants/assets.dart';
import '../constants/page_route.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalAuthentication _authentication = LocalAuthentication();

  final AppLogger _logger = AppLogger('SplashScreen');
  final OnboardingService _os = OnboardingService.getInstance();
  final SdkServices _sdk = SdkServices.getInstance();
  bool _masterImgKeyExists = false,
      _fingerAuthApproved = false,
      _fingerPrint = false;

  Future<void> _init() async {
    try {
      String? _currentAtSign;
      AtClientPreference? _preference;
      bool onboarded = false;
      Map<String, bool?> atSigns =
          await KeyChainManager.getInstance().getAtsignsWithStatus();
      if (atSigns.isNotEmpty) {
        _currentAtSign = atSigns.keys.firstWhere(
            (String key) => atSigns[key] == true,
            orElse: () => throw 'No AtSigns found');
        _preference = context.read<UserData>().atOnboardingPreference;
        _preference = context.read<UserData>().atOnboardingPreference
          ..privateKey = await KeyChainManager.getInstance()
              .getEncryptionPrivateKey(_currentAtSign);
        _os.setAtClientPreference = _preference;
        onboarded = await _os.onboard();
        context.read<UserData>().authenticated = onboarded;
        if (!onboarded) {
          showToast(
              context, 'Auto login failed. Please onboard with at sign again.',
              isError: true);
        } else {
          await AtClientManager.getInstance().setCurrentAtSign(
              _currentAtSign, PassmanEnv.appNamespace, _preference);
          AppServices.syncData();
          while (context.read<UserData>().syncStatus != SyncStatus.success) {
            await Future<void>.delayed(Duration.zero);
          }
          String? _profilePic = await _sdk.getProPic();
          if (_profilePic != null) {
            await AppServices.getProfilePic();
            context.read<UserData>().currentAtSign = _currentAtSign;
            context.read<UserData>().currentProfilePic =
                Base2e15.decode(_profilePic);
          }
          context.read<UserData>().isAdmin = await _sdk.isAdmin();
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
          await AppServices.getPasswords();
          await AppServices.getImages();
          await AppServices.getCards();
          await AppServices.getReports();
        }
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 3200));
      }
      _logger.finer('Checking done...');
      if (mounted) {
        await Navigator.pushReplacementNamed(
            context,
            onboarded
                ? _masterImgKeyExists &&
                        ((!_fingerPrint) ||
                            (_fingerPrint && _fingerAuthApproved))
                    ? PageRouteNames.masterPassword
                    : PageRouteNames.setMasterPassword
                : PageRouteNames.loginScreen);
      }
    } catch (e, s) {
      _logger.severe(e.toString(), e, s);
      return;
    }
  }

  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async {
      if (mounted && MediaQuery.of(context).size.width >= 500) {
        await Navigator.pushReplacementNamed(
            context, PageRouteNames.mobileDeviceScreen);
        return;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(),
      builder: (_, __) {
        return Scaffold(
          body: Center(
            child: Lottie.asset(
              Assets.logo,
              height: 200,
            ),
          ),
        );
      },
    );
  }
}
