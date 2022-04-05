// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../constants/page_route.dart';

class GetAtSignScreen extends StatefulWidget {
  const GetAtSignScreen({Key? key}) : super(key: key);

  @override
  State<GetAtSignScreen> createState() => _GetAtSignScreenState();
}

class _GetAtSignScreenState extends State<GetAtSignScreen> {
  Map<String, String> _atSignWithImgData = <String, String>{};
  final TextEditingController _emailController = TextEditingController();
  String? _email;
  bool _isLoading = false, _processing = false;

  bool _validateEmail() {
    if (_email == null || _email!.isEmpty) return false;
    return RegExp(
      r'^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$',
    ).hasMatch(_email!);
  }

  Future<Map<String, String>> getData() async {
    setState(() => _isLoading = true);
    _atSignWithImgData.clear();
    _atSignWithImgData = await AppServices.getNewAtSign();
    setState(() => _isLoading = false);
    return _atSignWithImgData;
  }

  @override
  void initState() {
    setState(() => _isLoading = true);
    Future<void>.microtask(() async => getData());
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
      body: Stack(
        children: <Widget>[
          Center(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        _atSignWithImgData['img']!,
                        height: 100,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _atSignWithImgData.containsKey('message')
                            ? _atSignWithImgData['message']!
                            : '@' + _atSignWithImgData['atSign']!,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          if (!_isLoading)
            Positioned(
              bottom: 68,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    await getData();
                  },
                  child: const Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.adaptive.arrow_back_rounded),
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashRadius: 0.1,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : _atSignWithImgData.containsKey('message')
                ? null
                : () async {
                    if (_atSignWithImgData.isEmpty) return;
                    context.read<NewUser>()
                      ..atSignWithImgData['atSign'] =
                          '@' + _atSignWithImgData['atSign']!
                      ..atSignWithImgData['img'] =
                          (await rootBundle.load(_atSignWithImgData['img']!))
                              .buffer
                              .asUint8List();
                    if (_emailController.text.isEmpty) {
                      setState(() => _processing = true);
                      await emailDialog(context);
                    } else {
                      setState(() => _processing = true);
                      bool _isValidMail = _validateEmail();
                      if (_isValidMail) {
                        bool mailSent = await AppServices.registerWithMail(<
                            String, String?>{
                          'email': _email,
                          'atsign': context
                              .read<NewUser>()
                              .atSignWithImgData['atSign']
                        });
                        if (mailSent) {
                          Navigator.of(context).pop();
                          showToast(context, 'Mail sent successfully');
                          context.read<NewUser>().atSignWithImgData['email'] =
                              _email;
                        } else {
                          Navigator.of(context).pop();
                          showToast(context,
                              'Something went wrong. Failed to send mail. Try again...',
                              isError: true);
                        }
                        setState(() => _processing = false);
                        await Navigator.pushNamed(
                            context, PageRouteNames.otpScreen);
                      } else {
                        showToast(context, 'Looks like email is not correct.',
                            isError: true);
                        await emailDialog(context);
                      }
                    }
                  },
        splashColor: Colors.transparent,
        highlightElevation: 0,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        focusElevation: 0,
        enableFeedback: true,
        tooltip: 'Next',
        backgroundColor: _isLoading ? Colors.grey : Colors.green,
        elevation: 0,
        child: _processing
            ? const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(
                Icons.adaptive.arrow_forward_rounded,
                color: Colors.white,
              ),
      ),
    );
  }

  Future<AlertDialog?> emailDialog(BuildContext context) {
    return showDialog<AlertDialog>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Enter your email',
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Container(
            height: 50,
            width: 350,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              autofocus: true,
              controller: _emailController,
              autocorrect: false,
              autofillHints: const <String>[AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'Enter your email',
                border: InputBorder.none,
              ),
              onSubmitted: (_) {
                setState(() {
                  _email = _emailController.text;
                  _processing = false;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
