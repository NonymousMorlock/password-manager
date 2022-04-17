// 🎯 Dart imports:
import 'dart:developer';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:image/image.dart' as imglib;
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/mark.paint.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/models/freezed/plots.model.dart';
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
  @override
  void initState() {
    _plots = <Plots>[];
    Future<void>.microtask(() async {
      if (!await AppServices.sdkServices.atClientManager.syncService
          .isInSync()) {
        AppServices.sdkServices.atClientManager.notificationService.subscribe();
        AppServices.syncData();
      }
      await AppServices.getMasterImage();
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
                ChangeNotifierProvider<UserData>.value(
                  value: context.watch<UserData>(),
                  builder: (BuildContext context, _) {
                    return Consumer<UserData>(
                      builder:
                          (BuildContext context, UserData value, Widget? _) {
                        return GestureDetector(
                          onPanDown: value.masterImage.isEmpty
                              ? null
                              : (DragDownDetails details) {
                                  double clickX =
                                      details.localPosition.dx.floorToDouble();
                                  double clickY =
                                      details.localPosition.dy.floorToDouble();
                                  log('(${(clickX / binSize).floorToDouble()}, ${(clickY / binSize).floorToDouble()})');
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
                              Container(
                                height: 300,
                                width: 300,
                                decoration: BoxDecoration(
                                  image: value.masterImage.isEmpty
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
                                child: value.masterImage.isEmpty
                                    ? Center(
                                        child: squareWidget(
                                          20,
                                          child: const CircularProgressIndicator
                                              .adaptive(),
                                        ),
                                      )
                                    : null,
                              ),
                              for (Plots pass in _plots!)
                                Marker(
                                  dx: pass.x * binSize,
                                  dy: pass.y * binSize,
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                vSpacer(50),
                _plots!.isEmpty
                    ? square(20)
                    : GestureDetector(
                        onLongPress: () => setState(() => _plots!.clear()),
                        onTap: () {
                          _plots!.removeLast();
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
                      ),
                vSpacer(50),
                MaterialButton(
                  mouseCursor: SystemMouseCursors.click,
                  color: AppTheme.primary,
                  elevation: 0,
                  highlightElevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Change image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () async {
                    setState(() => _plots!.clear());
                    await Navigator.pushNamed(
                        context, PageRouteNames.setMasterPassword,
                        arguments: true);
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
                value: context.watch<UserData>(),
                builder: (BuildContext context, _) => Consumer<UserData>(
                  builder: (BuildContext context, UserData value, Widget? _) =>
                      SyncIndicator(
                    size: 45,
                    child: value.currentProfilePic.isEmpty
                        ? GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, PageRouteNames.settings,
                                  arguments: false);
                            },
                            child: const Icon(
                              TablerIcons.user,
                              size: 15,
                            ),
                          )
                        : GestureDetector(
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, PageRouteNames.settings);
                            },
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
      floatingActionButton: (_plots!.isEmpty || _plots!.length < 4)
          ? null
          : FloatingActionButton(
              splashColor: Colors.transparent,
              hoverElevation: 0,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onPressed: (_plots!.isEmpty || _plots!.length < 4)
                  ? null
                  : () async {
                      imglib.Image? _img = imglib.decodeImage(
                          context.read<UserData>().masterImage.toList());
                      bool _valid =
                          await AppServices.validatePlots(_img!, _plots!);
                      showToast(
                          context, 'Plots are ${_valid ? 'valid' : 'invalid'}!',
                          isError: !_valid);
                      if (_valid) {
                        setState(() => _plots?.clear());
                        await Navigator.pushReplacementNamed(
                          context,
                          PageRouteNames.homeScreen,
                          // ModalRoute.withName(PageRouteNames.masterPassword),
                        );
                      }
                    },
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
