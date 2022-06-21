// 🎯 Dart imports:
import 'dart:developer';
import 'dart:io';

// � Package imports:
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
// � Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:secure_application/secure_application.dart';

// 🌎 Project imports:
import 'app/constants/assets.dart';
import 'app/constants/global.dart';
import 'app/constants/page_route.dart';
import 'app/provider/app_provider.dart';
import 'app/screens/home/home.screen.dart';
import 'app/screens/master_password/master_password.dart';
import 'app/screens/master_password/set_master_password.dart';
import 'app/screens/mobile.screen.dart';
import 'app/screens/onboard/activation.screen.dart';
import 'app/screens/onboard/get@sign.screen.dart';
import 'app/screens/onboard/loading.screen.dart';
import 'app/screens/onboard/login.screen.dart';
import 'app/screens/onboard/otp.screen.dart';
import 'app/screens/onboard/qr.screen.dart';
import 'app/screens/report/report.details.dart';
import 'app/screens/report/reports.screen.dart';
import 'app/screens/settings.screen.dart';
import 'app/screens/splash.screen.dart';
import 'app/screens/unknown.screen.dart';
import 'core/development/dev_err_screen.dart';
import 'core/services/app.service.dart';
import 'core/services/passman.env.dart';
import 'meta/extensions/logger.ext.dart';
import 'meta/notifiers/theme.notifier.dart';
import 'meta/notifiers/user_data.notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.rootLevel = 'finer';
  await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp]);
  ErrorWidget.builder = codeErrorScreenBuilder;
  String _logsPath =
      p.join((await getApplicationSupportDirectory()).path, 'logs');
  logFileLocation = _logsPath;
  log(_logsPath);
  if (!await Directory(_logsPath).exists()) {
    await Directory(_logsPath).create(recursive: true);
  }
  await AppServices.checkFirstRun();
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
        await AppServices.init(context.read<UserData>(), () async {
          await Navigator.pushNamed(context, PageRouteNames.reports);
          return;
        });
        String _path = (await getApplicationSupportDirectory()).path;
        String _downloadsPath = p.join(_path, 'downloads');
        if (!await Directory(_downloadsPath).exists()) {
          await Directory(_downloadsPath).create(recursive: true);
          _logger.finer('Created downloads directory at $_downloadsPath');
        }
        context.read<UserData>().atOnboardingPreference =
            await AppServices.sdkServices.getAtClientPreferences();
        OnboardingService.getInstance().setAtClientPreference =
            context.read<UserData>().atOnboardingPreference;
      },
    );
    _logger.finer('Initializing the app successfully completed.');
    super.initState();
  }

  final LocalAuthentication _authentication = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget? _) {
        return AnimatedTheme(
          data: value.currentTheme,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          child: MaterialApp(
            title: 'P@ssman',
            theme: value.currentTheme,
            builder: (BuildContext context, Widget? child) => SecureApplication(
              nativeRemoveDelay: 800,
              onNeedUnlock: (SecureApplicationController?
                  secureApplicationController) async {
                bool authResult = await _authentication.authenticate(
                  localizedReason: 'Authenticate to unlock',
                );
                if (authResult) {
                  secureApplicationController?.authSuccess(unlock: true);
                } else {
                  secureApplicationController?.authFailed(unlock: false);
                  secureApplicationController?.open();
                }
                return null;
              },
              child: child!,
            ),
            initialRoute: PageRouteNames.splashScreen,
            onGenerateRoute: (RouteSettings settings) {
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
                case PageRouteNames.settings:
                  return pageTransition(
                    settings,
                    const SettingsScreen(),
                  );
                case PageRouteNames.homeScreen:
                  return pageTransition(
                    settings,
                    const HomeScreen(),
                  );
                case PageRouteNames.reports:
                  return pageTransition(
                    settings,
                    const ReportsScreen(),
                  );
                case PageRouteNames.loadingScreen:
                  return pageTransition(
                    settings,
                    const LoadingDataScreen(),
                  );
                case PageRouteNames.mobileDeviceScreen:
                  return pageTransition(
                    settings,
                    const MobileDeviceScreen(),
                  );
                case PageRouteNames.reportDetails:
                  return pageTransition(
                    settings,
                    const ReportDetails(),
                  );
                default:
                  return pageTransition(
                    settings,
                    const UnknownRoute(),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
