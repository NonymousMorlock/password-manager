import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:at_base2e15/at_base2e15.dart';
import '../../app/constants/assets.dart';
import '../../app/constants/global.dart';
import '../../app/constants/keys.dart';
import '../../core/services/app.service.dart';
import '../notifiers/user_data.notifier.dart';
import 'file_upload_space.dart';

class SetProPic extends StatefulWidget {
  const SetProPic(this.image, {Key? key}) : super(key: key);
  final Uint8List image;
  @override
  State<SetProPic> createState() => _SetProPicState();
}

class _SetProPicState extends State<SetProPic> {
  bool _picked = false;
  Uint8List _pickedImg = Uint8List(0);
  Uint8List _avatar = Uint8List(0);
  @override
  void initState() {
    setState(() => _avatar = widget.image);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: MediaQuery.of(context).viewPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Choose a profile picture',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            vSpacer(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                if (!_picked && _pickedImg.isEmpty)
                  GestureDetector(
                    onTap: () async {
                      _avatar = await AppServices.readLocalfilesAsBytes(
                          Assets.getRandomAvatar());
                      setState(() {});
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.memory(
                        _avatar,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                if (!_picked && _pickedImg.isEmpty)
                  const Text(
                    'Or',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                _picked && _pickedImg.isNotEmpty
                    ? GestureDetector(
                        onTap: () async {
                          Set<PlatformFile> _imgSet =
                              await AppServices.uploadFile(FileType.image);
                          Uint8List _img = await AppServices.readFilesAsBytes(
                              _imgSet.first.path!);
                          if (_img.isNotEmpty) {
                            setState(() {
                              _picked = true;
                              _pickedImg = _img;
                            });
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.memory(
                            _pickedImg,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                        ),
                      )
                    : FileUploadSpace(
                        size: const Size(150, 100),
                        onTap: (_) async {
                          if (_.isNotEmpty) {
                            Uint8List _img =
                                await AppServices.readLocalfilesAsBytes(
                                    _.first.path!);
                            setState(() {
                              _picked = true;
                              _pickedImg = _img;
                            });
                          }
                        },
                        multipleFiles: false,
                        fileType: FileType.image,
                        uploadMessage: 'Select image from gallery',
                        child: const Icon(
                          TablerIcons.photo,
                        ),
                      ),
              ],
            ),
            vSpacer(30),
            GestureDetector(
              onTap: () async {
                Uint8List _bytes = _pickedImg.isNotEmpty ? _pickedImg : _avatar;
                bool _imgUpdated = await AppServices.sdkServices.put(
                    Keys.profilePicKey..value?.value = Base2e15.encode(_bytes));
                if (_imgUpdated) {
                  context.read<UserData>().currentProfilePic = _bytes;
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            vSpacer(20),
          ],
        ),
      ),
    );
  }
}
