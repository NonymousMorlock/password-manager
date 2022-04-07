// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';

import '../../core/services/app.service.dart';
import '../../meta/components/sync_indicator.dart';
import '../../meta/notifiers/user_data.dart';
import '../constants/page_route.dart';
import '../provider/listeners/user_data.listener.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
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
      body: const Center(
        child: TextButton(
          onPressed: AppServices.syncData,
          child: Text('Sync'),
        ),
      ),
    );
  }
}
