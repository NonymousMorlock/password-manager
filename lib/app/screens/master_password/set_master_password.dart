// 🐦 Flutter imports:

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_base2e15/at_base2e15.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons/tabler_icons.dart';

// 🌎 Project imports:
import '../../../core/services/app.service.dart';
import '../../../meta/components/adaptive_loading.dart';
import '../../../meta/components/file_upload_space.dart';
import '../../../meta/components/sync_indicator.dart';
import '../../../meta/components/toast.dart';
import '../../../meta/models/key.model.dart';
import '../../../meta/models/value.model.dart';
import '../../../meta/notifiers/new_user.dart';
import '../../../meta/notifiers/user_data.dart';
import '../../constants/global.dart';

class SetMasterPasswordScreen extends StatefulWidget {
  const SetMasterPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetMasterPasswordScreen> createState() =>
      _SetMasterPasswordScreenState();
}

class _SetMasterPasswordScreenState extends State<SetMasterPasswordScreen> {
  PlatformFile? _file;
  bool _isLoading = false;
  @override
  void initState() {
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
                        child: const Icon(
                          TablerIcons.upload,
                          color: Colors.green,
                          size: 30,
                        ),
                        uploadMessage:
                            'Select a image to\nset as master password',
                      )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          border: Border.all(
                            color: Colors.green,
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
                      vSpacer(50),
                      InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: const Text(
                          'Change Image',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          List<PlatformFile> _anotherFile =
                              await AppServices.uploadFile(FileType.image);
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
          ? FloatingActionButton(
              onPressed: () async {
                PassKey(
                  key: 'masterpassimg',
                  sharedBy: AppServices.sdkServices.currentAtSign,
                  isPublic: false,
                  isHidden: true,
                  value: Value(
                    value: Base2e15.encode(
                        await AppServices.readLocalfilesAsBytes(_file!.path!)),
                    labelName: 'Master password image',
                    isHidden: true,
                  ),
                );
              },
              child: const Icon(
                TablerIcons.check,
                color: Colors.white,
              ),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
