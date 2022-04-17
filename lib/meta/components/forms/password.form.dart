// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../app/constants/constants.dart';
import '../../../app/constants/global.dart';
import '../../../app/constants/keys.dart';
import '../../../app/constants/theme.dart';
import '../../../core/services/app.service.dart';
import '../../models/freezed/password.model.dart';
import '../../models/key.model.dart';
import '../../notifiers/user_data.dart';
import '../adaptive_loading.dart';
import '../filled_text_field.dart';

class PasswordForm extends StatefulWidget {
  const PasswordForm({Key? key}) : super(key: key);

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  late TextEditingController _uPassController, _uNameController;
  bool _loading = false, _showPassword = false;
  late Uint8List _favData;
  @override
  void initState() {
    _uNameController = TextEditingController();
    _uPassController = TextEditingController();
    _favData = Uint8List(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22.0),
                      child: Text(
                        'Account details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              height: 50,
                              width: 50,
                              color: AppTheme.disabled.withOpacity(0.2),
                              child: Center(
                                child: _loading
                                    ? const AdaptiveLoading()
                                    : _favData.isEmpty
                                        ? const Center(child: Text('🌐'))
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.memory(
                                              _favData,
                                              height: 30,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    vSpacer(20),
                    FilledTextField(
                      width: 350,
                      hint: 'Website Url',
                      onChanged: (_) async {
                        if (_.isEmpty) {
                          setState(() {
                            _favData = Uint8List(0);
                            _loading = false;
                          });
                          return;
                        }
                        if (RegExp(
                                r"^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:/?#[\]@!\$&'\(\)\*\+,;=.]+$")
                            .hasMatch(_)) {
                          setState(() => _loading = true);
                          await AppServices.getFavicon(_)
                              .then((Uint8List value) {
                            setState(() {
                              _favData = value;
                              _loading = false;
                            });
                          });
                        } else {
                          setState(() {
                            _favData = Uint8List(0);
                            _loading = false;
                          });
                        }
                      },
                    ),
                    vSpacer(30),
                    FilledTextField(
                      width: 350,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      controller: _uNameController,
                      hint: 'Username',
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    vSpacer(30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FilledTextField(
                          width: 280,
                          enableInteractiveSelection: false,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: _uPassController,
                          obsecureText: !_showPassword,
                          hint: 'Password',
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppTheme.disabled.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Text(
                                _showPassword ? '🔓' : '🔒',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    vSpacer(40),
                    MaterialButton(
                      onPressed: (_uNameController.text.isEmpty ||
                              _uPassController.text.isEmpty)
                          ? null
                          : () async {
                              String _id = 'password_' + Constants.uuid;
                              Password _password = Password(
                                id: _id,
                                name: _uNameController.text,
                                password: _uPassController.text,
                                favicon: _favData.isEmpty
                                    ? '🌐'
                                    : Base2e15.encode(_favData),
                              );
                              PassKey _key = Keys.passwordKey
                                ..key = _id
                                ..value?.value = _password.toJson();
                              bool _isPut =
                                  await AppServices.sdkServices.put(_key);
                              if (_isPut) {
                                context
                                    .read<UserData>()
                                    .passwords
                                    .add(_password);
                                _uPassController.clear();
                                _uNameController.clear();
                                _favData = Uint8List(0);
                                _loading = false;
                                _showPassword = false;
                                setState(() {});
                                Navigator.pop(context);
                              }
                            },
                      child: const Text('Save'),
                    ),
                    vSpacer(20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
