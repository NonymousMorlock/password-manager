// 🎯 Dart imports:
import 'dart:developer';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/mark.paint.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/models/plots.model.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';
import '../../constants/theme.dart';

class MasterPasswordScreen extends StatefulWidget {
  const MasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<MasterPasswordScreen> createState() => _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends State<MasterPasswordScreen> {
  List<Plots>? _plots;
  bool _isLoading = true;
  @override
  void initState() {
    _plots = <Plots>[];
    Future<void>.microtask(() async {
      if (context.read<UserData>().syncStatus != SyncStatus.started ||
          context.read<UserData>().syncStatus != SyncStatus.success) {
        AppServices.sdkServices.atClientManager.notificationService.subscribe();
        AppServices.syncData();
      }
      Uint8List? _img = await AppServices.sdkServices.getMasterImage();
      if (_img != null) {
        setState(() {
          _isLoading = false;
        });
        context.read<UserData>().masterImage = _img;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onPanDown: (DragDownDetails details) {
                    double clickX = details.localPosition.dx.floorToDouble();
                    double clickY = details.localPosition.dy.floorToDouble();
                    log('($clickX, $clickY)');
                    _plots!.add(
                      Plots(
                        x: (clickX / binSize).floorToDouble(),
                        y: (clickY / binSize).floorToDouble(),
                      ),
                    );
                    setState(() {
                      _plots!.length;
                    });
                  },
                  child: Stack(
                    children: <Widget>[
                      ChangeNotifierProvider<UserData>.value(
                        value: context.read<UserData>(),
                        builder: (BuildContext context, _) {
                          return Consumer<UserData>(
                            builder: (BuildContext context, UserData value,
                                Widget? _) {
                              return Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  image: (_isLoading ||
                                          value.masterImage.isEmpty)
                                      ? null
                                      : DecorationImage(
                                          image: MemoryImage(value.masterImage),
                                          fit: BoxFit.fill,
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppTheme.primary,
                                    width: 3,
                                  ),
                                ),
                                child: (_isLoading || value.masterImage.isEmpty)
                                    ? Center(
                                        child: squareWidget(
                                          20,
                                          child: const CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      )
                                    : null,
                              );
                            },
                          );
                        },
                      ),
                      for (Plots pass in _plots!)
                        Marker(
                          dx: pass.x * binSize,
                          dy: pass.y * binSize,
                        ),
                    ],
                  ),
                ),
                if (_plots!.isNotEmpty) vSpacer(50),
                _plots!.isNotEmpty
                    ? GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _plots!.clear();
                          });
                        },
                        onTap: _plots!.isEmpty
                            ? null
                            : () {
                                _plots!.removeLast();
                                // _plots!.removeRange(0, _plots!.length);
                                setState(() => _plots!.length);
                              },
                        child: Text(
                          'Undo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                vSpacer(50),
                MaterialButton(
                  mouseCursor: SystemMouseCursors.click,
                  color: AppTheme.primary,
                  elevation: 0,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  highlightElevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Change image',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () async {
                    _plots?.clear();
                    await Navigator.pushReplacementNamed(
                        context, PageRouteNames.setMasterPassword);
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            right: 10,
            child: Padding(
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
                                  image: Image.memory(value.currentProfilePic)
                                      .image,
                                ),
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
      floatingActionButton: (_plots!.isEmpty || _plots!.length < 4)
          ? null
          : FloatingActionButton(
              splashColor: Colors.transparent,
              hoverElevation: 0,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed:
                  (_plots!.isEmpty || _plots!.length < 4) ? null : () async {},
              child: const Icon(
                TablerIcons.check,
                color: Colors.white,
              ),
              backgroundColor: (_plots!.isEmpty || _plots!.length < 4)
                  ? AppTheme.primary
                  : AppTheme.primary,
            ),
    );
  }
}
