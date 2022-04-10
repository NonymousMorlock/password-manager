// 🎯 Dart imports:
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../core/services/app.service.dart';
import '../../meta/components/adaptive_loading.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/components/toast.dart';
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';
import '../../meta/notifiers/user_data.dart';
import '../constants/keys.dart';
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
  bool _editing = false, _imagePreview = false, _loading = false;
  final PassKey _nameKey = Keys.nameKey
    ..sharedBy = AppServices.sdkServices.currentAtSign;

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
      body: Center(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: UserDataListener(
                    builder: (_, UserData _userData) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _loading
                            ? const AdaptiveLoading()
                            : GestureDetector(
                                onLongPress: () async {
                                  setState(() {
                                    _nameFocusNode.unfocus();
                                    _imagePreview = true;
                                  });
                                  await showModalBottomSheet(
                                    elevation: 0,
                                    isDismissible: false,
                                    barrierColor: Colors.transparent,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SizedBox(
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            IconButton(
                                              splashRadius: 0.01,
                                              onPressed: () async {
                                                setState(() => _loading = true);
                                                List<PlatformFile> _list =
                                                    await AppServices
                                                        .uploadFile(
                                                            FileType.image);
                                                if (_list.isNotEmpty) {
                                                  context
                                                          .read<UserData>()
                                                          .currentProfilePic =
                                                      await AppServices
                                                          .readFilesAsBytes(
                                                              _list
                                                                  .first.path!);
                                                  PassKey _key = Keys
                                                      .profilePicKey
                                                    ..sharedBy = context
                                                        .read<UserData>()
                                                        .currentAtSign
                                                    ..value = Value(
                                                      value: Base2e15.encode(
                                                          context
                                                              .read<UserData>()
                                                              .currentProfilePic),
                                                      type: 'profilepic',
                                                      labelName: 'Profile pic',
                                                    );
                                                  bool _put = await AppServices
                                                      .sdkServices
                                                      .put(_key);
                                                  setState(
                                                      () => _loading = false);
                                                  showToast(
                                                      context,
                                                      _put
                                                          ? 'Profile pic updated successfully'
                                                          : 'Error in updating profilepic',
                                                      isError: !_put);
                                                } else {
                                                  setState(
                                                      () => _loading = false);
                                                  showToast(context,
                                                      'Changing profile pic aborted.',
                                                      isError: true);
                                                }
                                              },
                                              icon: const Icon(
                                                TablerIcons.edit,
                                                color: Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              splashRadius: 0.01,
                                              onPressed: () {},
                                              icon: const Icon(
                                                TablerIcons.trash,
                                                color: Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              splashRadius: 0.01,
                                              onPressed: () {
                                                setState(() {
                                                  _imagePreview = false;
                                                });
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(
                                                TablerIcons.x,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                onLongPressEnd: (_) {
                                  // setState(() => _imagePreview = false);
                                  // Navigator.pop(context);
                                },
                                child: Hero(
                                  tag: 'propic',
                                  transitionOnUserGestures: true,
                                  child: ClipOval(
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
                                    _userNameController.text = 'Your Name';
                                  }
                                  _nameFocusNode.unfocus();
                                },
                                onSubmitted: (_) {
                                  if (_.isEmpty) {
                                    _userNameController.text = 'Your Name';
                                  }
                                  _nameFocusNode.unfocus();
                                },
                                cursorOpacityAnimates: true,
                                cursorColor: AppTheme.primary,
                                backgroundCursorColor: Colors.transparent,
                              ),
                              Text(
                                _userData.currentAtSign,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const TextButton(
                  onPressed: AppServices.syncData,
                  child: Text('Sync'),
                ),
              ],
            ),
            if (_imagePreview)
              Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: _loading
                      ? const AdaptiveLoading()
                      : Hero(
                          tag: 'propic',
                          transitionOnUserGestures: true,
                          child: ClipOval(
                            child: Image(
                              width: 300,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                              image: Image.memory(context
                                      .watch<UserData>()
                                      .currentProfilePic)
                                  .image,
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
