// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
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
  final AppLogger _logger = AppLogger('SplashScreen');
  final OnboardingService _os = OnboardingService.getInstance();
  final SdkServices _sdk = SdkServices.getInstance();
  bool _masterImgKeyExists = false;
  Future<void> _init() async {
    try {
      String? _currentAtSign;
      AtClientPreference? _preference;
      bool onboarded = false;
      Map<String, bool?> atSigns =
          await KeyChainManager.getInstance().getAtsignsWithStatus();
      if (atSigns.isNotEmpty) {
        _currentAtSign = atSigns.keys.firstWhere((String key) => atSigns[key]!);
        _preference = context.read<UserData>().atOnboardingPreference;
        _preference = context.read<UserData>().atOnboardingPreference
          ..privateKey = await KeyChainManager.getInstance()
              .getEncryptionPrivateKey(_currentAtSign);
        _os.setAtClientPreference = _preference;
        onboarded = await _os.onboard();
        if (!onboarded) {
          showToast(
              context, 'Auto login failed. Please onboard with at sign again.',
              isError: true);
        } else {
          await AtClientManager.getInstance().setCurrentAtSign(
              _currentAtSign, PassmanEnv.appNamespace, _preference);
          String? a = await _sdk.getProPic();
          if (a != null) {
            context.read<UserData>().currentProfilePic = Base2e15.decode(a);
          } else {
            context.read<UserData>().currentProfilePic =
                await AppServices.readLocalfilesAsBytes(Assets.logoImg);
          }
          _masterImgKeyExists = await _sdk.checkMasterImageKey();
        }
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 3200));
      }
      _logger.finer('Checking done...');
      await Navigator.pushReplacementNamed(
          context,
          onboarded
              ? _masterImgKeyExists
                  ? PageRouteNames.masterPassword
                  : PageRouteNames.setMasterPassword
              : PageRouteNames.loginScreen);
    } catch (e) {
      _logger.severe(e.toString());
      return;
    }
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
