// 🎯 Dart imports:

// 🐦 Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/forms/card.form.dart';
import '../../../meta/components/forms/image.form.dart';
import '../../../meta/components/forms/password.form.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/tab_indicator.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/page_route.dart';
import '../../constants/theme.dart';
import '../../provider/listeners/user_data.listener.dart';
import 'tabs/cards.screen.dart';
import 'tabs/images.screen.dart';
import 'tabs/passwords.screen.dart';

// 📦 Package imports:

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);
    Future<void>.delayed(Duration.zero, () async {
      await AppServices.getPasswords();
      await AppServices.getImages();
      await AppServices.getCards();
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(TablerIcons.chevron_left),
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, PageRouteNames.masterPassword);
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
                              fit: BoxFit.cover,
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
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      context: context,
                      builder: (_) {
                        return _tabController?.index == 0
                            ? const PasswordForm()
                            : _tabController?.index == 1
                                ? const ImagesForm()
                                : const CardsForm();
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
}
