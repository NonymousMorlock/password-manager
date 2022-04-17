// 🎯 Dart imports:
import 'dart:typed_data';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../app/constants/global.dart';
import '../../app/constants/keys.dart';
import '../../core/services/app.service.dart';
import '../models/key.model.dart';
import '../models/value.model.dart';
import '../notifiers/user_data.dart';
import 'adaptive_loading.dart';
import 'toast.dart';

class ChangeProPic extends StatefulWidget {
  const ChangeProPic({Key? key}) : super(key: key);

  @override
  State<ChangeProPic> createState() => _ChangeProPicState();
}

class _ChangeProPicState extends State<ChangeProPic> {
  Uint8List _previewPic = Uint8List(0);
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Hero(
                tag: 'propic',
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: _loading
                      ? squareWidget(
                          300,
                          child: const AdaptiveLoading(),
                        )
                      : Image(
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          image: Image.memory(_previewPic.isEmpty
                                  ? context.watch<UserData>().currentProfilePic
                                  : _previewPic)
                              .image,
                        ),
                ),
              ),
              vSpacer(20),
              Container(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 300,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          Set<PlatformFile> _list =
                              await AppServices.uploadFile(FileType.image);
                          if (_list.isNotEmpty) {
                            Uint8List _pic = await AppServices.readFilesAsBytes(
                                _list.first.path!);
                            setState(() {
                              _loading = false;
                              _previewPic = _pic;
                            });
                          } else {
                            setState(() {
                              _loading = false;
                              _previewPic = Uint8List(0);
                            });
                            showToast(context, 'Changing profile pic aborted.',
                                isError: true);
                          }
                        },
                        child: const Icon(
                          TablerIcons.edit,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _previewPic = Uint8List(0);
                          });
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          TablerIcons.x,
                          color: Colors.black,
                        ),
                      ),
                      if (_previewPic.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            PassKey _key = Keys.profilePicKey
                              ..sharedBy =
                                  context.read<UserData>().currentAtSign
                              ..value = Value(
                                value: Base2e15.encode(_previewPic),
                                type: 'profilepic',
                                labelName: 'Profile pic',
                              );
                            bool _put = await AppServices.sdkServices.put(_key);
                            setState(() {
                              _loading = false;
                            });
                            showToast(
                                context,
                                _put
                                    ? 'Profile pic updated successfully'
                                    : 'Error in updating profilepic',
                                isError: !_put);
                            if (_put) {
                              setState(() {
                                context.read<UserData>().currentProfilePic =
                                    _previewPic;
                                _previewPic = Uint8List(0);
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: const Icon(
                            TablerIcons.check,
                            color: Colors.black,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
