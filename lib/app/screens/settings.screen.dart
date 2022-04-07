import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

import '../../core/services/app.service.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/components/toast.dart';
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';
import '../../meta/notifiers/user_data.dart';
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
  bool _editing = false;
  final PassKey _nameKey = PassKey(
    key: 'name',
    sharedBy: AppServices.sdkServices.currentAtSign,
    isPublic: true,
  );

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
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: UserDataListener(
                builder: (_, UserData _userData) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Hero(
                      tag: 'propic',
                      transitionOnUserGestures: true,
                      child: ClipOval(
                        child: Image(
                          height: 100,
                          width: 100,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                          image:
                              Image.memory(_userData.currentProfilePic).image,
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
      ),
    );
  }
}
