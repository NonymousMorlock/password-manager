// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/notifiers/user_data.dart';

class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  @override
  void initState() {
    Future<void>.microtask(() async {
      if (context.read<UserData>().syncStatus != SyncStatus.started ||
          context.read<UserData>().syncStatus != SyncStatus.success) {
        AppServices.sdkServices.atClientManager.notificationService.subscribe();
        AppServices.syncData();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ChangeNotifierProvider<UserData>.value(
              value: context.read<UserData>(),
              builder: (BuildContext context, _) => Consumer<UserData>(
                builder: (BuildContext context, UserData value, Widget? _) =>
                    SyncIndicator(
                  size: value.currentProfilePic.isEmpty ? 15 : 45,
                  child: value.currentProfilePic.isEmpty
                      ? null
                      : GestureDetector(
                          onTap: () {},
                          child: Hero(
                            tag: 'profilePic',
                            createRectTween: (Rect? begin, Rect? end) =>
                                RectTween(
                              begin: begin?.translate(10, 0),
                              end: end?.translate(0, 10),
                            ),
                            transitionOnUserGestures: true,
                            child: ClipOval(
                              child: Image(
                                height: 45,
                                width: 45,
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                                image:
                                    Image.memory(value.currentProfilePic).image,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: const <Widget>[
          Center(
            child: Text('MasterPasswordScreen'),
          ),
        ],
      ),
    );
  }
}
