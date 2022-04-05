// 🐦 Flutter imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/app.service.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../../meta/notifiers/user_data.dart';

class SetMasterPasswordScreen extends StatefulWidget {
  const SetMasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetMasterPasswordScreen> createState() =>
      _SetMasterPasswordScreenState();
}

class _SetMasterPasswordScreenState extends State<SetMasterPasswordScreen> {
  @override
  void initState() {
    context.read<NewUser>().atSignWithImgData.clear();
    Future<void>.microtask(() {
      if (context.read<UserData>().syncStatus != SyncStatus.started ||
          context.read<UserData>().syncStatus != SyncStatus.success) {
        AppServices.refresh();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 45,
                  width: 45,
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: context.watch<UserData>().syncStatus ==
                              SyncStatus.notStarted
                          ? Colors.transparent
                          : context.watch<UserData>().syncStatus ==
                                  SyncStatus.started
                              ? Colors.yellow[600]!
                              : context.watch<UserData>().syncStatus ==
                                      SyncStatus.success
                                  ? Colors.green
                                  : Colors.red,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(47),
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: Hero(
                      tag: 'profilePic',
                      createRectTween: (Rect? begin, Rect? end) => RectTween(
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
                          image: Image.memory(
                                  context.watch<UserData>().currentProfilePic)
                              .image,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('SetMasterPasswordScreen'),
      ),
    );
  }
}
