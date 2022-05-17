// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'dart:async';

import 'package:at_commons/src/keystore/at_key.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:local_auth/local_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../core/services/app.service.dart';
import '../../core/services/helper.service.dart';
import '../../meta/components/adaptive_loading.dart';
import '../../meta/components/change_propic.dart';
import '../../meta/components/forms/report.form.dart';
import '../../meta/components/settings/category.settings.dart';
import '../../meta/components/settings/tile.settings.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/components/toast.dart';
import '../../meta/extensions/logger.ext.dart';
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';
import '../../meta/notifiers/theme.dart';
import '../../meta/notifiers/user_data.dart';
import '../constants/assets.dart';
import '../constants/global.dart';
import '../constants/keys.dart';
import '../constants/page_route.dart';
import '../constants/theme.dart';
import '../provider/listeners/user_data.listener.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _userNameController = TextEditingController(),
      _reportController = TextEditingController(),
      _titleController = TextEditingController(text: 'Title of the report');
  final FocusNode _nameFocusNode = FocusNode(), _titleFocusNode = FocusNode();
  bool _editing = false, _saving = false, _enableFingerprint = false;
  final AppLogger _logger = AppLogger('Settings screen');
  final PassKey _nameKey = Keys.nameKey
    ..sharedBy = AppServices.sdkServices.currentAtSign;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isLoading = false;
  PackageInfo? packageInfo;
  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async {
      packageInfo = await PackageInfo.fromPlatform();
      String? _name = await AppServices.sdkServices.get(_nameKey);
      context.read<UserData>().userName = _name;
      if (mounted) _nameFocusNode.unfocus();
      setState(() {
        _userNameController.text =
            context.read<UserData>().userName ?? 'Your Name';
      });
    });
    super.initState();
  }

  Future<void> setUserName() async {
    setState(() {
      _editing = false;
    });
    _nameFocusNode.unfocus();
    _nameKey.value = Value(
      value: _userNameController.text,
      type: 'username',
      labelName: 'User name',
    );
    bool _nameUpdated = await AppServices.sdkServices.put(_nameKey);
    if (_nameUpdated) {
      context.read<UserData>().userName = _userNameController.text;
    }
    showToast(context,
        _nameUpdated ? 'Name updated successfully' : 'Failed to update name',
        isError: !_nameUpdated);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _reportController.dispose();
    _titleController.dispose();
    _nameFocusNode.dispose();
    _titleFocusNode.dispose();
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
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 0.01,
          icon: Icon(_editing ? TablerIcons.x : TablerIcons.chevron_left,
              color: Theme.of(context).iconTheme.color),
          onPressed: _editing
              ? () {
                  _nameFocusNode.unfocus();
                  setState(() {
                    _editing = false;
                    _userNameController.text =
                        context.read<UserData>().userName ?? 'Your Name';
                  });
                }
              : () => Navigator.pop(context),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _editing
                ? InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: setUserName,
                    child: const Icon(TablerIcons.check),
                  )
                : UserDataListener(
                    builder: (_, __) => SyncIndicator(size: 15),
                  ),
          )
        ],
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        maintainBottomViewPadding: true,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: UserDataListener(
                            builder: (_, UserData _userData) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  GestureDetector(
                                    onLongPress: () async {
                                      setState(_nameFocusNode.unfocus);
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        barrierColor: Colors.transparent,
                                        builder: (_) {
                                          return const ChangeProPic();
                                        },
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image(
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                        image: Image.memory(
                                                _userData.currentProfilePic)
                                            .image,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        EditableText(
                                          controller: _userNameController,
                                          focusNode: _nameFocusNode,
                                          // style: TextStyle(
                                          //   fontSize: 20,
                                          //   color: Theme.of(context)
                                          //       .textTheme
                                          //       .labelLarge!
                                          //       .color,
                                          //   fontWeight: FontWeight.bold,
                                          // ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          onChanged: (_) {
                                            setState(() {
                                              if (_.isEmpty) {
                                                _editing = false;
                                              } else {
                                                _editing = true;
                                              }
                                            });
                                          },
                                          onEditingComplete: () {
                                            if (_userNameController
                                                .text.isEmpty) {
                                              _userNameController.text =
                                                  'Your Name';
                                            }
                                            _nameFocusNode.unfocus();
                                          },
                                          onSubmitted: (_) {
                                            if (_.isEmpty) {
                                              _userNameController.text =
                                                  'Your Name';
                                            }
                                            _nameFocusNode.unfocus();
                                          },
                                          cursorOpacityAnimates: true,
                                          cursorColor: AppTheme.primary,
                                          backgroundCursorColor:
                                              Colors.transparent,
                                        ),
                                        Text(
                                          _userData.currentAtSign +
                                              (_userData.isAdmin
                                                  ? ' (Admin)'
                                                  : ''),
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SettingsCategory(
                          category: 'General',
                          children: <Widget>[
                            SettingsCard(
                              height: 60,
                              leading: Icon(
                                TablerIcons.file,
                                color:
                                    iconThemedColor(context, AppTheme.primary),
                              ),
                              lable: 'Backup keys file',
                              subLable: 'Backup your keys file to a safe place',
                              trailing: _saving
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: squareWidget(
                                        20,
                                        child: const AdaptiveLoading(),
                                      ),
                                    )
                                  : null,
                              onTap: () async {
                                setState(() => _saving = true);
                                await AppServices.saveAtKeys(
                                  context.read<UserData>().currentAtSign,
                                  context
                                      .read<UserData>()
                                      .atOnboardingPreference
                                      .downloadPath!,
                                  MediaQuery.of(context).size,
                                );
                                await AppServices.deleteAtKeysFiles(context
                                    .read<UserData>()
                                    .atOnboardingPreference
                                    .downloadPath!);
                                setState(() => _saving = false);
                              },
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            SettingsCard(
                              height: 60,
                              leading: Icon(
                                TablerIcons.fingerprint,
                                color:
                                    iconThemedColor(context, Colors.lightBlue),
                              ),
                              onTap: null,
                              lable: 'Fingerprint',
                              subLable: 'Use your biometric for more security',
                              trailing: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: UserDataListener(
                                  builder:
                                      (BuildContext context, UserData data) {
                                    return Switch.adaptive(
                                      value: data.fingerprintAuthEnabled,
                                      onChanged: (_) async {
                                        bool canCheckBiometrics =
                                            await _localAuth.canCheckBiometrics;
                                        if (!canCheckBiometrics) {
                                          _logger.severe(
                                              'No biometrics available');
                                          return;
                                        } else {
                                          bool _authenticated =
                                              await _localAuth.authenticate(
                                            localizedReason:
                                                'Authenticate to enable fingerprint',
                                          );
                                          if (_authenticated) {
                                            setState(() {
                                              _enableFingerprint =
                                                  !_enableFingerprint;
                                              context
                                                      .read<UserData>()
                                                      .fingerprintAuthEnabled =
                                                  _enableFingerprint;
                                            });
                                          }
                                        }
                                        PassKey _fingerprint = Keys
                                            .fingerprintKey
                                          ..value?.value = _enableFingerprint;
                                        bool _put = await AppServices
                                            .sdkServices
                                            .put(_fingerprint);
                                        if (_put) {
                                          context
                                                  .read<UserData>()
                                                  .fingerprintAuthEnabled =
                                              _enableFingerprint;
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            SettingsCard(
                              height: 60,
                              leading: Icon(
                                TablerIcons.paint,
                                color: iconThemedColor(context, Colors.purple),
                              ),
                              onTap: null,
                              lable: 'Change Theme',
                              subLable: 'Pick a theme for your app',
                              trailing: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Switch.adaptive(
                                  value: context
                                      .watch<AppThemeNotifier>()
                                      .isDarkTheme,
                                  onChanged: (_) async {
                                    context
                                        .read<AppThemeNotifier>()
                                        .isDarkTheme = _;
                                    PassKey _theme = Keys.themeKey
                                      ..value?.value = context
                                          .read<AppThemeNotifier>()
                                          .isDarkTheme;
                                    await AppServices.sdkServices.put(_theme);
                                  },
                                ),
                              ),
                            ),
                            if (context.watch<UserData>().isAdmin)
                              const Divider(
                                height: 0,
                                thickness: 1,
                              ),
                            if (context.watch<UserData>().isAdmin)
                              SettingsCard(
                                height: 60,
                                leading: Icon(
                                  TablerIcons.user_plus,
                                  color:
                                      iconThemedColor(context, Colors.black54),
                                ),
                                onTap: null,
                                lable: 'Add admins',
                                subLable: 'Add someone as admins',
                                trailing: const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text('(Only Admins)'),
                                ),
                              ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            SettingsCard(
                              height: 60,
                              leading: Icon(
                                TablerIcons.ghost,
                                color: iconThemedColor(context, Colors.red),
                              ),
                              onTap: () async {
                                Future<void> _waitForSync(
                                    {Function? onDone}) async {
                                  while (AppServices.sdkServices.atClientManager
                                      .syncService.isSyncInProgress) {
                                    await Future<void>.delayed(
                                        const Duration(milliseconds: 100));
                                  }
                                  setState(() => _isLoading = false);
                                  if (onDone != null) {
                                    onDone();
                                  }
                                }

                                setState(() => _isLoading = true);
                                List<AtKey> allKeys = await AppServices
                                    .sdkServices
                                    .getAllKeys(regex: 'passman');
                                for (AtKey atKey in allKeys) {
                                  if (atKey.key != null) {
                                    await AppServices.sdkServices
                                        .delete(atKey.key!, () async {
                                      await _waitForSync(onDone: () async {
                                        if (await AppServices.logout()) {
                                          await Navigator.pushReplacementNamed(
                                              context, '/login');
                                        }
                                      });
                                    });
                                  }
                                }
                              },
                              lable: 'Reset',
                              subLable:
                                  'Reset all your data and removes all your data',
                            ),
                          ],
                        ),
                        vSpacer(30),
                        SettingsCategory(
                          category: 'About',
                          children: <Widget>[
                            SettingsCard(
                              height: 60,
                              leading: Image.asset(
                                Assets.logoImg,
                                scale: 6,
                              ),
                              onTap: null,
                              lable: 'About',
                              subLable: 'Learn more about P@ssword manager',
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            SettingsCard(
                              height: 60,
                              leading: Icon(
                                TablerIcons.report,
                                color: iconThemedColor(
                                    context, Colors.amber[700]!),
                              ),
                              onTap: () async {
                                context.read<UserData>().isAdmin
                                    ? await Navigator.pushNamed(
                                        context, PageRouteNames.reports)
                                    : await reportSheet(context);
                              },
                              lable: 'Report',
                              subLable: 'Report a bug or send feedback',
                            ),
                          ],
                        ),
                        vSpacer(30),
                        SettingsCategory(
                          category: 'Account',
                          children: <Widget>[
                            SettingsCard(
                              height: 60,
                              lable: 'Logout',
                              subLable:
                                  'Logout ${context.read<UserData>().currentAtSign}',
                              leading: Icon(
                                TablerIcons.power,
                                color: iconThemedColor(context, Colors.red),
                              ),
                              onTap: () async {
                                bool _loggedOut = await AppServices.logout();
                                if (_loggedOut) {
                                  context.read<AppThemeNotifier>().isDarkTheme =
                                      false;
                                  await Navigator.pushReplacementNamed(
                                      context, '/login');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    vSpacer(50),
                    Center(
                      child: Text(
                        'Made with \u{1F49A} by Minnu',
                        style: TextStyle(
                          color: AppTheme.disabled,
                        ),
                      ),
                    ),
                    vSpacer(10),
                    Center(
                      child: Text(
                        'Version : ${packageInfo?.version}',
                        style: TextStyle(
                          color: AppTheme.disabled,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const Opacity(
                opacity: 1,
                child: Center(
                  child: AdaptiveLoading(),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> reportSheet(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (_) {
        return const ReportForm();
      },
    );
  }
}
