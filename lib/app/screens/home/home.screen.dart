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
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/page_route.dart';
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
  String _title = 'Passwords';
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
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: Icon(
            TablerIcons.chevron_left,
            color: Theme.of(context).appBarTheme.iconTheme!.color,
          ),
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
        children: <Widget>[
          PasswordsPage(context),
          const ImagesPage(),
          CardsPage(context),
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
                  labelColor: Theme.of(context).primaryColor,
                  indicator: CircleTabIndicator(
                    color: Theme.of(context).primaryColor,
                    radius: 3,
                  ),
                  onTap: (_) {
                    setState(() {
                      _ == 0
                          ? _title = 'Passwords'
                          : _ == 1
                              ? _title = 'Images'
                              : _title = 'Cards';
                    });
                  },
                  physics: const BouncingScrollPhysics(),
                  unselectedLabelColor: Theme.of(context).iconTheme.color,
                  tabs: const <Widget>[
                    Tab(
                      icon: Icon(
                        TablerIcons.key,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        TablerIcons.photo,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        TablerIcons.credit_card,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: IconButton(
                  focusColor: Colors.transparent,
                  onPressed: () async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      context: _scaffoldKey.currentContext!,
                      builder: (_) {
                        return _tabController?.index == 0
                            ? const PasswordForm()
                            : _tabController?.index == 1
                                ? const ImagesForm()
                                : CardsForm(_scaffoldKey.currentContext!);
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
