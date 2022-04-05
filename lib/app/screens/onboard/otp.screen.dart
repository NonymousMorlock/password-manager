// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/otp.form.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/models/qr.model.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';

// 📦 Package imports:

// 🌎 Project imports:

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  bool resend = false;
  double progress = 1.0;

  void start() {
    if (controller.isAnimating) {
      controller.stop();
      setState(() => resend = true);
    } else {
      controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);
      setState(() => resend = false);
    }
  }

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 5),
    );

    controller.addListener(() {
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          resend = true;
        });
      }
    });
    start();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.memory(
                    context.read<NewUser>().newUserData['img'],
                    height: 100,
                  ),
                  Center(
                    child: Text(
                      context.read<NewUser>().newUserData['atSign'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  vSpacer(30),
                  Center(
                    child: Text(
                      'We sent code to ' +
                          context
                              .read<NewUser>()
                              .newUserData['email']
                              .toString()
                              .substring(0, 4) +
                          '****',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  vSpacer(30),
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                ],
              ),
              Center(
                child: OtpForm(
                  onResend: () async {
                    bool mailSent =
                        await AppServices.registerWithMail(<String, String?>{
                      'email': context.read<NewUser>().newUserData['email'],
                      'atsign': context.read<NewUser>().newUserData['atSign']
                    });
                    if (mailSent) {
                      setState(() {
                        resend = false;
                      });
                      controller.reset();
                      start();
                      showToast(context, 'Code resent successfully.');
                    } else {
                      setState(() => resend = true);
                      showToast(context, 'Failed to resend the code.',
                          isError: true);
                    }
                  },
                  onSubmit: () async {
                    String? _cram = await AppServices.getCRAM(<String, dynamic>{
                      'email': context.read<NewUser>().newUserData['email'],
                      'atsign': context
                          .read<NewUser>()
                          .newUserData['atSign']
                          .toString()
                          .replaceFirst('@', ''),
                      'otp': context.read<NewUser>().newUserData['otp'],
                      'confirmation': true,
                    });
                    if (_cram != null) {
                      context
                          .read<UserData>()
                          .atOnboardingPreference
                          .cramSecret = _cram.split(':')[1];
                      context.read<NewUser>().setQrData = QrModel(
                          atSign: _cram.split(':')[0],
                          cramSecret: _cram.split(':')[1]);
                      showToast(context, 'OTP verified successfully.');
                      await Navigator.pushNamed(
                          context, PageRouteNames.activatingAtSign);
                    } else {
                      showToast(context, 'Invalid OTP.', isError: true);
                    }
                  },
                  resend: resend,
                ),
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              splashRadius: 0.1,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: () async => Navigator.pushNamedAndRemoveUntil(
                context,
                PageRouteNames.loginScreen,
                ModalRoute.withName(PageRouteNames.loginScreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
