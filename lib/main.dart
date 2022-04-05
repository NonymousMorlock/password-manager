// 🎯 Dart imports:
import 'dart:developer';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'app/constants/assets.dart';
import 'app/constants/global.dart';
import 'app/constants/page_route.dart';
import 'app/provider/app_provider.dart';
import 'app/screens/home.screen.dart';
import 'app/screens/master_password/master_password.dart';
import 'app/screens/master_password/set_master_password.dart';
import 'app/screens/onboard/activation.screen.dart';
import 'app/screens/onboard/get@sign.screen.dart';
import 'app/screens/onboard/login.screen.dart';
import 'app/screens/onboard/otp.screen.dart';
import 'app/screens/onboard/qr.screen.dart';
import 'app/screens/splash.screen.dart';
import 'app/screens/unknown.screen.dart';
import 'core/development/dev_err_screen.dart';
import 'core/services/app.service.dart';
import 'core/services/passman.env.dart';
import 'meta/extensions/logger.ext.dart';
import 'meta/notifiers/user_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.rootLevel = 'finer';
  // await KeyChainManager.getInstance().clearKeychainEntries();
  ErrorWidget.builder = codeErrorScreenBuilder;
  String _logsPath =
      p.join((await getApplicationSupportDirectory()).path, 'logs');
  logFileLocation = _logsPath;
  log(_logsPath);
  if (!await Directory(_logsPath).exists()) {
    await Directory(_logsPath).create(recursive: true);
  }
  await PassmanEnv.loadEnv(Assets.configFile);
  runApp(
    const MultiProviders(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLogger _logger = AppLogger('MyApp');
  @override
  void initState() {
    _logger.finer('Started initializing the app...');
    Future<void>.microtask(
      () async {
        AppServices.init(Provider.of<UserData>(context, listen: false));
        String _path = (await getApplicationSupportDirectory()).path;
        String _downloadsPath = p.join(_path, 'downloads');
        if (!await Directory(_downloadsPath).exists()) {
          await Directory(_downloadsPath).create(recursive: true);
        }
        AppConstants.rootDomain = PassmanEnv.rootDomain;
        OnboardingService.getInstance().setAtClientPreference =
            context.read<UserData>().atOnboardingPreference
              ..commitLogPath = p.join(_path, 'commitLog')
              ..hiveStoragePath = p.join(_path, 'hiveStorage')
              ..downloadPath = _downloadsPath
              ..syncRegex = PassmanEnv.syncRegex
              ..isLocalStoreRequired = true
              ..syncPageLimit = 500
              ..rootDomain = PassmanEnv.rootDomain
              ..namespace = PassmanEnv.appNamespace;
      },
    );
    _logger.finer('Initializing the app successfully completed.');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P@ssman',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      initialRoute: PageRouteNames.splashScreen,
      onGenerateRoute: (RouteSettings settings) {
        _logger.finer('Navigating to ${settings.name}');
        switch (settings.name) {
          case PageRouteNames.splashScreen:
            return pageTransition(
              settings,
              const SplashScreen(),
            );
          case PageRouteNames.loginScreen:
            return pageTransition(
              settings,
              const LoginScreen(),
            );
          case PageRouteNames.registerScreen:
            return pageTransition(
              settings,
              const GetAtSignScreen(),
            );
          case PageRouteNames.setMasterPassword:
            return pageTransition(
              settings,
              const SetMasterPasswordScreen(),
            );
          case PageRouteNames.masterPassword:
            return pageTransition(
              settings,
              const MasterPasswordScreen(),
            );
          case PageRouteNames.qrScreen:
            return pageTransition(
              settings,
              const QRScreen(),
            );
          case PageRouteNames.otpScreen:
            return pageTransition(
              settings,
              const OtpScreen(),
            );
          case PageRouteNames.activatingAtSign:
            return pageTransition(
              settings,
              const ActivateAtSignScreen(),
            );
          case PageRouteNames.homeScreen:
            return pageTransition(
              settings,
              const HomeScreen(),
            );
          default:
            return pageTransition(
              settings,
              const UnknownRoute(),
            );
        }
      },
    );
  }
}
