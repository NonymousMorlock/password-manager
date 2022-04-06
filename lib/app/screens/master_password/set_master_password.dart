// 🐦 Flutter imports:

// 🎯 Dart imports:
import 'dart:developer';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../core/services/enc/encode.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/file_upload_space.dart';
import '../../../meta/components/mark.paint.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/extensions/logger.ext.dart';
import '../../../meta/extensions/plots.ext.dart';
import '../../../meta/models/key.model.dart';
import '../../../meta/models/plots.model.dart';
import '../../../meta/models/value.model.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/global.dart';
import '../../constants/page_route.dart';
import '../../constants/theme.dart';

class SetMasterPasswordScreen extends StatefulWidget {
  const SetMasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetMasterPasswordScreen> createState() =>
      _SetMasterPasswordScreenState();
}

class _SetMasterPasswordScreenState extends State<SetMasterPasswordScreen> {
  final AppLogger _logger = AppLogger('Set Master Password Screen');
  PlatformFile? _file;
  bool _isLoading = false, _imgSaved = false, _saving = false;
  List<Plots>? _plots;
  @override
  void initState() {
    _plots = <Plots>[];
    context.read<NewUser>().newUserData.clear();
    Future<void>.microtask(() {
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
    // for (Plots item in _plots!) {
    //   log('${item.x}  ${item.y}');
    // }
    // String pointString =
    //     _plots!.map((Plots pass) => '(${pass.x} ${pass.y})').join('');
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: _file == null
                ? _isLoading
                    ? const AdaptiveLoading()
                    : FileUploadSpace(
                        fileType: FileType.image,
                        onTap: (_) {
                          if (_.isEmpty) {
                            showToast(context, 'Image not picked',
                                isError: true);
                            return;
                          }
                          setState(() {
                            _file = _.first;
                          });
                        },
                        child: Icon(
                          TablerIcons.upload,
                          color: AppTheme.primary,
                          size: 30,
                        ),
                        uploadMessage:
                            'Select a image to\nset as master password',
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onPanDown: (DragDownDetails details) {
                          double clickX =
                              details.localPosition.dx.floorToDouble();
                          double clickY =
                              details.localPosition.dy.floorToDouble();
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
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                image: _isLoading
                                    ? null
                                    : DecorationImage(
                                        image: AssetImage(_file!.path!),
                                        fit: BoxFit.fill,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                                border: _imgSaved
                                    ? null
                                    : Border.all(
                                        color: AppTheme.primary,
                                        width: 3,
                                      ),
                              ),
                              child: _isLoading
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
                      ),
                      vSpacer(50),
                      if (_imgSaved)
                        const Text(
                          'Image saved successfully.\nHold tight we get back you to the login screen',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      if (!_imgSaved)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
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
                                    child:
                                        const Icon(TablerIcons.arrow_back_up),
                                  )
                                : square(24),
                            InkWell(
                              mouseCursor: SystemMouseCursors.click,
                              splashFactory: NoSplash.splashFactory,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              child: Text(
                                'Change Image',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                List<PlatformFile> _anotherFile =
                                    await AppServices.uploadFile(
                                        FileType.image);
                                if (_anotherFile.isEmpty) {
                                  showToast(context, 'Image not picked',
                                      isError: true);
                                  setState(() => _isLoading = false);
                                  return;
                                }
                                setState(() {
                                  _file = _anotherFile.first;
                                  _isLoading = false;
                                });
                              },
                            ),
                            square(24),
                          ],
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
      floatingActionButton: _file != null
          ? !_imgSaved && _plots!.length >= 4
              ? FloatingActionButton(
                  splashColor: Colors.transparent,
                  hoverElevation: 0,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onPressed: ((_plots!.isEmpty || _plots!.length < 4) ||
                          _saving)
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          PassKey _passkey = PassKey(
                            key: 'masterpassimg',
                            sharedBy: AppServices.sdkServices.currentAtSign,
                            isPublic: false,
                            isHidden: true,
                            value: Value(
                              labelName: 'Master password image',
                              isHidden: true,
                            ),
                          );
                          try {
                            imglib.Image? _img = imglib.decodeImage(
                                (await AppServices.readFilesAsBytes(
                                        _file!.path!))
                                    .toList());
                            String _msg = '';
                            for (Plots pass in _plots!) {
                              _msg += pass.join();
                            }
                            if (_img != null) {
                              Uint8List? encryptedData =
                                  await Encode.getInstance().encodeImage(
                                image: _img,
                                content: _msg,
                                key: await AppServices.getCryptKey(),
                              );
                              if (encryptedData == null) {
                                _logger.severe(
                                    'Error occured while encoding data into image');
                                return;
                              }
                              _passkey.value?.value =
                                  Base2e15.encode(encryptedData.toList());
                              bool _isPut =
                                  await AppServices.sdkServices.put(_passkey);
                              if (_isPut) {
                                _plots?.clear();
                                setState(() {
                                  _saving = false;
                                  _imgSaved = true;
                                });
                                // showToast(context, 'Image saved successfully');
                                await Navigator.pushReplacementNamed(
                                    context, PageRouteNames.masterPassword);
                              } else {
                                showToast(context,
                                    'Error occured while saving image to secondary',
                                    isError: true);
                                setState(() => _saving = true);
                                return;
                              }
                            } else {
                              showToast(context, 'Error while reading image',
                                  isError: true);
                              setState(() => _saving = true);
                              return;
                            }
                          } on Exception catch (e, s) {
                            _logger.severe(
                                'Error occured while encoding data into image',
                                e,
                                s);
                            showToast(context, 'Error while encoding data',
                                isError: true);
                            setState(() => _saving = true);
                            return;
                          }
                        },
                  child: _saving
                      ? const AdaptiveLoading()
                      : const Icon(
                          TablerIcons.check,
                          color: Colors.white,
                        ),
                  backgroundColor: (_plots!.isEmpty || _plots!.length < 4)
                      ? AppTheme.primary
                      : AppTheme.primary,
                )
              : null
          : null,
    );
  }
}
