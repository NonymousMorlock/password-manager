// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:at_onboarding_flutter/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../app/constants/global.dart';
import '../../../app/constants/theme.dart';
import '../../notifiers/new_user.notifier.dart';
import '../adaptive_loading.dart';
import '../toast.dart';

class OtpForm extends StatefulWidget {
  const OtpForm(
      {Key? key,
      required this.context,
      required this.resend,
      required this.onResend,
      required this.onSubmit})
      : super(key: key);
  final bool resend;
  final GestureTapCallback onResend;
  final VoidCallback onSubmit;
  final BuildContext context;
  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  late TextEditingController pin1, pin2, pin3, pin4;
  late FocusNode _otpFocusNode1, _otpFocusNode2, _otpFocusNode3, _otpFocusNode4;
  @override
  void initState() {
    _otpFocusNode1 = FocusNode();
    _otpFocusNode2 = FocusNode();
    _otpFocusNode3 = FocusNode();
    _otpFocusNode4 = FocusNode();
    pin1 = TextEditingController();
    pin2 = TextEditingController();
    pin3 = TextEditingController();
    pin4 = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _otpFocusNode1.dispose();
    _otpFocusNode2.dispose();
    _otpFocusNode3.dispose();
    _otpFocusNode4.dispose();
    pin1.dispose();
    pin2.dispose();
    pin3.dispose();
    pin4.dispose();
    super.dispose();
  }

  void nextFocus(FocusNode nextFocus) => nextFocus.requestFocus();
  final GlobalKey _otpFormKey = GlobalKey();
  bool _submitting = false, _resending = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _otpFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              OtpField(
                controller: pin1,
                focusNode: _otpFocusNode1,
                onChanged: (_) {
                  if (_.isNotEmpty) {
                    nextFocus(_otpFocusNode2);
                  }
                },
              ),
              OtpField(
                focusNode: _otpFocusNode2,
                controller: pin2,
                onChanged: (_) {
                  if (_.isNotEmpty) {
                    nextFocus(_otpFocusNode3);
                  }
                },
                onClear: (RawKeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.backspace ||
                      event.logicalKey == LogicalKeyboardKey.delete) {
                    _otpFocusNode1.requestFocus();
                  }
                },
              ),
              OtpField(
                focusNode: _otpFocusNode3,
                controller: pin3,
                onChanged: (_) {
                  if (_.isNotEmpty) {
                    nextFocus(_otpFocusNode4);
                  }
                },
                onClear: (RawKeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.backspace ||
                      event.logicalKey == LogicalKeyboardKey.delete) {
                    _otpFocusNode2.requestFocus();
                  }
                },
              ),
              OtpField(
                focusNode: _otpFocusNode4,
                controller: pin4,
                onChanged: (_) {
                  if (_.isNotEmpty) {
                    _otpFocusNode4.unfocus();
                  }
                },
                onClear: (RawKeyEvent event) {
                  if (event.logicalKey == LogicalKeyboardKey.backspace ||
                      event.logicalKey == LogicalKeyboardKey.delete) {
                    _otpFocusNode3.requestFocus();
                  }
                },
              ),
            ],
          ),
          vSpacer(70),
          Column(
            children: <Widget>[
              _submitting
                  ? const AdaptiveLoading()
                  : MaterialButton(
                      mouseCursor: SystemMouseCursors.click,
                      color: _resending
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor,
                      elevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                      focusElevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onPressed: _resending
                          ? null
                          : () {
                              if ((pin1.text +
                                          pin2.text +
                                          pin3.text +
                                          pin4.text)
                                      .length <
                                  4) {
                                showToast(widget.context, 'Please enter valid OTP',
                                    isError: true);
                                return;
                              }
                              setState(() => _submitting = true);
                              context
                                  .read<NewUser>()
                                  .newUserData
                                  .addAll(<String, String>{
                                'otp': pin1.text +
                                    pin2.text +
                                    pin3.text +
                                    pin4.text
                              });
                              widget.onSubmit();
                              setState(() => _submitting = false);
                            },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
              vSpacer(30),
              _resending
                  ? const AdaptiveLoading()
                  : InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          color: widget.resend
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: widget.resend
                          ? () {
                              setState(() => _resending = true);
                              pin1.clear();
                              pin2.clear();
                              pin3.clear();
                              pin4.clear();
                              _otpFocusNode1.requestFocus();
                              widget.onResend();
                              setState(() => _resending = false);
                            }
                          : null,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class OtpField extends StatefulWidget {
  const OtpField({
    Key? key,
    this.onChanged,
    this.focusNode,
    this.controller,
    this.autoFocus = false,
    this.onClear,
  }) : super(key: key);
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autoFocus;
  final TextEditingController? controller;
  final ValueChanged<RawKeyEvent>? onClear;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late FocusNode _keyboardFocusNode;

  @override
  void initState() {
    _keyboardFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.grey[200],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: RawKeyboardListener(
          focusNode: _keyboardFocusNode,
          onKey: widget.onClear,
          child: TextFormField(
            controller: widget.controller,
            autofocus: widget.autoFocus,
            focusNode: widget.focusNode,
            autocorrect: false,
            keyboardType: TextInputType.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(1),
              UpperCaseInputFormatter(),
              FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]')),
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
