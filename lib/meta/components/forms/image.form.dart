// 🎯 Dart imports:
import 'dart:io';
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../app/constants/constants.dart';
import '../../../app/constants/global.dart';
import '../../../app/constants/keys.dart';
import '../../../app/constants/theme.dart';
import '../../../core/services/app.service.dart';
import '../../models/freezed/image.model.dart';
import '../../models/key.model.dart';
import '../adaptive_loading.dart';
import '../file_upload_space.dart';

class ImagesForm extends StatefulWidget {
  const ImagesForm({Key? key}) : super(key: key);

  @override
  State<ImagesForm> createState() => _ImagesFormState();
}

class _ImagesFormState extends State<ImagesForm> {
  late TextEditingController _folderNameController;
  final Set<PlatformFile> _images = <PlatformFile>{};
  final FocusNode _folderNameFocusNode = FocusNode();
  bool _put = false;
  @override
  void initState() {
    _folderNameController = TextEditingController(text: 'Folder Name');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 22.0),
                    child: EditableText(
                      textAlign: TextAlign.center,
                      autocorrect: false,
                      controller: _folderNameController,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      onChanged: (String value) => setState(() {}),
                      onSubmitted: (String value) =>
                          setState(_folderNameFocusNode.unfocus),
                      backgroundCursorColor: Colors.transparent,
                      cursorColor: AppTheme.primary,
                      focusNode: _folderNameFocusNode,
                    ),
                  ),
                  vSpacer(40),
                  if (_images.isNotEmpty)
                    Wrap(
                      children: <Widget>[
                        for (final PlatformFile image in _images)
                          GestureDetector(
                            onLongPress: () =>
                                setState(() => _images.remove(image)),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: FileImage(File(image.path!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (_images.isNotEmpty) vSpacer(40),
                  FileUploadSpace(
                    uploadMessage: 'Upload your images',
                    multipleFiles: true,
                    child: Icon(
                      TablerIcons.photo,
                      color: AppTheme.primary,
                    ),
                    fileType: FileType.image,
                    onTap: (Set<PlatformFile> _imgs) {
                      setState(() {
                        _images.addAll(_imgs);
                      });
                    },
                  ),
                  vSpacer(40),
                  _put
                      ? const AdaptiveLoading(
                          size: 40,
                        )
                      : MaterialButton(
                          onPressed: (_folderNameController.text.isEmpty ||
                                  _folderNameController.text == 'Folder Name')
                              ? null
                              : () async {
                                  setState(() => _put = false);
                                  Set<String> _imagesData = <String>{};
                                  for (int i = 0; i < _images.length; i++) {
                                    Uint8List _bytes =
                                        await AppServices.readFilesAsBytes(
                                            _images.elementAt(i).path!);
                                    _imagesData.add(Base2e15.encode(_bytes));
                                  }
                                  String _id = Constants.uuid;
                                  Images _imgData = Images(
                                    folderId:
                                        _folderNameController.text + '_' + _id,
                                    folderName: _folderNameController.text,
                                    images: _imagesData,
                                    imageCount: _images.length,
                                    createdAt: DateTime.now(),
                                  );
                                  PassKey _imgKeys = Keys.imagesKey
                                    ..key = 'images_' + _id
                                    ..value?.value = _imgData.toJson();
                                  bool _isPut = await AppServices.sdkServices
                                      .put(_imgKeys);
                                  if (_isPut) {
                                    await AppServices.getImages();
                                    setState(() => _put = false);
                                    _folderNameController.clear();
                                    _imagesData.clear();
                                    _images.clear();
                                    Navigator.pop(
                                        context, _folderNameController.text);
                                  }
                                },
                          child: const Text('Save'),
                        ),
                  vSpacer(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
