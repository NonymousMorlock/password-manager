// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/filled_text_field.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/tab_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/models/freezed/password.model.dart';
import '../../../meta/models/key.model.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/constants.dart';
import '../../constants/global.dart';
import '../../constants/keys.dart';
import '../../constants/page_route.dart';
import '../../constants/theme.dart';
import '../../provider/listeners/user_data.listener.dart';
import 'cards.screen.dart';
import 'images.screen.dart';
import 'passwords.screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  Uint8List _favData = Uint8List(0);
  bool _loading = false, _showPassword = false;
  late TextEditingController _uPassController, _uNameController;
  @override
  void initState() {
    _uNameController = TextEditingController();
    _uPassController = TextEditingController();
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.chevron_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserDataListener(
              builder: (BuildContext _ctx, UserData _userValue) =>
                  SyncIndicator(
                size: _userValue.currentProfilePic.isEmpty ? 15 : 45,
                child: _userValue.currentProfilePic.isEmpty
                    ? null
                    : GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(_ctx, PageRouteNames.settings);
                        },
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: 'propic',
                          child: ClipOval(
                            child: Image(
                              height: 45,
                              width: 45,
                              fit: BoxFit.fill,
                              gaplessPlayback: true,
                              image: Image.memory(_userValue.currentProfilePic)
                                  .image,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        dragStartBehavior: DragStartBehavior.start,
        children: const <Widget>[
          PasswordsPage(),
          ImagesPage(),
          CardsPage(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.transparent,
              ),
              width: 270,
              height: 50,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBar(
                  controller: _tabController!,
                  labelColor: AppTheme.primary,
                  indicator: CircleTabIndicator(
                    color: AppTheme.primary,
                    radius: 3,
                  ),
                  physics: const BouncingScrollPhysics(),
                  unselectedLabelColor: AppTheme.disabled,
                  tabs: const <Widget>[
                    Tab(
                      icon: Icon(TablerIcons.key),
                    ),
                    Tab(
                      icon: Icon(TablerIcons.photo),
                    ),
                    Tab(
                      icon: Icon(TablerIcons.credit_card),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppTheme.primary,
              ),
              child: Center(
                child: IconButton(
                  focusColor: Colors.transparent,
                  onPressed: () async {
                    _favData = Uint8List(0);
                    await showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      context: context,
                      builder: (_) {
                        return _tabController?.index == 0
                            ? passwordForm()
                            : const AdaptiveLoading();
                      },
                    );
                  },
                  icon: const Icon(
                    TablerIcons.plus,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatefulBuilder passwordForm() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
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
                                    borderRadius: BorderRadius.circular(25),
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
                  await AppServices.getFavicon(_).then((Uint8List value) {
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
              onPressed: () async {
                if (_uNameController.text.isEmpty ||
                    _uPassController.text.isEmpty) {
                  showToast(context, 'Looks like you missing some fields',
                      isError: true);
                  return;
                }
                Password _password = Password(
                  name: _uNameController.text,
                  password: _uPassController.text,
                  favicon: _favData.isEmpty ? '🌐' : Base2e15.encode(_favData),
                );
                PassKey _key = Keys.passwordKey
                  ..key = 'password_' + Constants.uuid
                  ..value?.value = _password.toJson();
                bool _isPut = await AppServices.sdkServices.put(_key);
                if (_isPut) {
                  context.read<UserData>().passwords.add(_password);
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
      );
    });
  }
}
