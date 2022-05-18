// 🐦 Flutter imports:

// 🎯 Dart imports:
import 'dart:developer';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:permission_handler/permission_handler.dart';
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
import '../../../meta/models/freezed/plots.model.dart';
import '../../../meta/models/key.model.dart';
import '../../../meta/notifiers/new_user.notifier.dart';
import '../../../meta/notifiers/user_data.notifier.dart';
import '../../constants/global.dart';
import '../../constants/keys.dart';
import '../../constants/page_route.dart';

class SetMasterPasswordScreen extends StatefulWidget {
  const SetMasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetMasterPasswordScreen> createState() =>
      _SetMasterPasswordScreenState();
}

class _SetMasterPasswordScreenState extends State<SetMasterPasswordScreen> {
  final AppLogger _logger = AppLogger('Set Master Password Screen');
  PlatformFile? _file;
  bool _isLoading = false, _imgSaved = false, _saving = false, _canPop = false;
  Uint8List? _imgBytes;
  List<Plots>? _plots;
  @override
  void initState() {
    _plots = <Plots>[];
    context.read<NewUser>().newUserData.clear();
    Future<void>.delayed(Duration.zero, () async {
      await AppServices.startMonitor();
      await AppServices.checkPermission(<Permission>[
        Permission.storage,
        Permission.photos,
        Permission.manageExternalStorage
      ]);
      setState(() => _canPop =
          ModalRoute.of(context)!.settings.arguments as bool? ?? false);
      if (!await AppServices.sdkServices.atClientManager.syncService
          .isInSync()) {
        AppServices.syncData();
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
            child: _file == null && _imgBytes == null
                ? _isLoading
                    ? const AdaptiveLoading()
                    : FileUploadSpace(
                        fileType: FileType.image,
                        onTap: (_) async {
                          setState(() => _isLoading = true);
                          if (_.isEmpty) {
                            showToast(context, 'Image not picked',
                                isError: true);
                            setState(() => _isLoading = false);
                            return;
                          }
                          Uint8List _bytes =
                              await AppServices.readFilesAsBytes(_.first.path!);
                          setState(() {
                            _imgBytes = _bytes;
                            _file = _.first;
                            _isLoading = false;
                          });
                        },
                        child: Icon(
                          TablerIcons.upload,
                          color: Theme.of(context).primaryColor,
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
                                image: _isLoading
                                    ? null
                                    : DecorationImage(
                                        image: MemoryImage(_imgBytes!),
                                        fit: BoxFit.cover,
                                      ),
                                borderRadius: BorderRadius.circular(10),
                                border: _imgSaved
                                    ? null
                                    : Border.all(
                                        color: Theme.of(context).primaryColor,
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
                              child: Text(
                                'Change Image',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                Set<PlatformFile> _anotherFile =
                                    await AppServices.uploadFile(
                                        FileType.image);
                                if (_anotherFile.isEmpty) {
                                  showToast(context, 'Image not picked',
                                      isError: true);
                                  setState(() => _isLoading = false);
                                  return;
                                }
                                Uint8List _bytes =
                                    await AppServices.readFilesAsBytes(
                                        _anotherFile.first.path!);
                                setState(() {
                                  _imgBytes = _bytes;
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
                                fit: BoxFit.cover,
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
          _canPop
              ? Positioned(
                  top: 60,
                  left: 10,
                  child: IconButton(
                    splashRadius: 0.1,
                    onPressed: () {
                      _file = null;
                      _plots?.clear();
                      Navigator.pop(context);
                    },
                    icon: const Icon(TablerIcons.x),
                  ),
                )
              : square(0),
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
                          PassKey _passkey = Keys.masterImgKey
                            ..sharedBy = AppServices.sdkServices.currentAtSign;
                          try {
                            Uint8List _pickedImage =
                                await AppServices.readFilesAsBytes(
                                    _file!.path!);
                            imglib.Image? _img =
                                imglib.decodeImage(_pickedImage.toList());
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
                                showToast(context, 'Image saved successfully');
                                _file = null;
                                context.read<UserData>().masterImage =
                                    encryptedData;
                                _plots?.clear();
                                _canPop
                                    ? Navigator.pop(context)
                                    : await Navigator.pushReplacementNamed(
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
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor,
                )
              : null
          : null,
    );
  }
}
