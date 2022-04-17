// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../core/services/app.service.dart';
import '../../meta/components/adaptive_loading.dart';
import '../../meta/components/change_propic.dart';
import '../../meta/components/settings/settings_category.dart';
import '../../meta/components/settings/settings_tile.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/components/toast.dart';
import '../../meta/extensions/logger.ext.dart';
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';
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
  final TextEditingController _userNameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  bool _editing = false, _saving = false, _enableFingerprint = false;
  final AppLogger _logger = AppLogger('Settings screen');
  final PassKey _nameKey = Keys.nameKey
    ..sharedBy = AppServices.sdkServices.currentAtSign;
  final LocalAuthentication _localAuth = LocalAuthentication();
  @override
  void initState() {
    Future<void>.delayed(Duration.zero, () async {
      String? _name = await AppServices.sdkServices.get(_nameKey);
      context.read<UserData>().userName = _name;
      _nameFocusNode.unfocus();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 0.01,
          icon: Icon(_editing ? TablerIcons.x : TablerIcons.chevron_left),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
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
        child: SingleChildScrollView(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    fit: BoxFit.fill,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    EditableText(
                                      controller: _userNameController,
                                      focusNode: _nameFocusNode,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                        if (_userNameController.text.isEmpty) {
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
                                      backgroundCursorColor: Colors.transparent,
                                    ),
                                    Text(
                                      _userData.currentAtSign +
                                          (_userData.isAdmin ? ' (Admin)' : ''),
                                      style:
                                          Theme.of(context).textTheme.caption,
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
                            color: AppTheme.primary,
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
                            setState(() => _saving = false);
                          },
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        Opacity(
                          opacity: context.watch<UserData>().syncStatus ==
                                  SyncStatus.success
                              ? 1
                              : 0.5,
                          child: SettingsCard(
                            height: 60,
                            leading: const Icon(
                              TablerIcons.fingerprint,
                              color: Colors.lightBlue,
                            ),
                            onTap: null,
                            lable: 'Fingerprint',
                            subLable: 'Use your biometric for more security',
                            trailing: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: UserDataListener(
                                builder: (BuildContext context, UserData data) {
                                  return Switch.adaptive(
                                    value: data.fingerprintAuthEnabled,
                                    onChanged: data.syncStatus !=
                                            SyncStatus.success
                                        ? null
                                        : (_) async {
                                            bool canCheckBiometrics =
                                                await _localAuth
                                                    .canCheckBiometrics;
                                            if (!canCheckBiometrics) {
                                              _logger.severe(
                                                  'No biometrics available');
                                              return;
                                            } else {
                                              bool _authenticated =
                                                  await _localAuth.authenticate(
                                                localizedReason:
                                                    'Authenticate to enable fingerprint',
                                                biometricOnly: true,
                                                stickyAuth: true,
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
                                              ..value?.value =
                                                  _enableFingerprint;
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
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        const Opacity(
                          opacity: 0.3,
                          child: SettingsCard(
                            height: 60,
                            leading: Icon(
                              TablerIcons.paint,
                              color: Colors.purple,
                            ),
                            onTap: null,
                            lable: 'Change Theme',
                            subLable: 'Pick a theme for your app',
                            trailing: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text('(Alpha)'),
                            ),
                          ),
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
                            color: Colors.amber[700],
                          ),
                          onTap: () {
                            context.read<UserData>().isAdmin
                                ? Navigator.pushNamed(
                                    context, PageRouteNames.reports)
                                : showModalBottomSheet(
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
                                      return Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0),
                                              child: Text(
                                                'Report your issue here',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            vSpacer(20),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                              child: Container(
                                                height: 100,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3.0,
                                                        horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey[200],
                                                ),
                                                child: TextFormField(
                                                  maxLines: 30,
                                                  decoration: InputDecoration(
                                                    fillColor: AppTheme.grey
                                                        .withOpacity(0.2),
                                                    hintText:
                                                        'Oops, Sorry to get you here. Please tell us what happened.',
                                                    hintStyle: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            vSpacer(15),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: GestureDetector(
                                                child: Text(
                                                  'Send',
                                                  style: TextStyle(
                                                    color: AppTheme.primary,
                                                  ),
                                                ),
                                                onTap: () {},
                                              ),
                                            ),
                                            vSpacer(15),
                                          ],
                                        ),
                                      );
                                    },
                                  );
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
                          leading: const Icon(
                            TablerIcons.power,
                            color: Colors.red,
                          ),
                          onTap: () async {
                            bool _loggedOut = await AppServices.logout();
                            if (_loggedOut) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
