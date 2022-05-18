// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';

// 🌎 Project imports:
import '../../core/services/app.service.dart';
import 'adaptive_loading.dart';

class FileUploadSpace extends StatelessWidget {
  const FileUploadSpace({
    required this.onTap,
    this.uploadMessage,
    this.onDismmisTap,
    this.dismissable = false,
    this.child,
    this.messageStyle,
    this.assetPath,
    this.fileType = FileType.any,
    this.boxColor,
    this.multipleFiles = false,
    this.extensions,
    Key? key,
    this.isUploading = false,
    this.size = const Size(300, 150),
  }) : super(key: key);
  final Function(Set<PlatformFile>) onTap;
  final VoidCallback? onDismmisTap;
  final String? uploadMessage;
  final String? assetPath;
  final FileType? fileType;
  final Color? boxColor;
  final Widget? child;
  final Size? size;
  final TextStyle? messageStyle;
  final bool multipleFiles;
  final List<String>? extensions;
  final bool isUploading;
  final bool dismissable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () async => onTap.call(await AppServices.uploadFile(
              fileType, multipleFiles, extensions)),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const <double>[10, 10],
            strokeCap: StrokeCap.round,
            strokeWidth: 3,
            color: boxColor ?? Theme.of(context).primaryColor,
            child: Container(
              width: size?.width ?? 300,
              height: size?.height ?? 150,
              decoration: BoxDecoration(
                color:
                    boxColor ?? Theme.of(context).primaryColor.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  child ??
                      Image.asset(
                        assetPath!,
                        height: 50,
                      ),
                  const SizedBox(
                    height: 10,
                  ),
                  isUploading
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          height: 10,
                          width: 10,
                          child: const AdaptiveLoading())
                      : Text(
                          uploadMessage ?? 'Upload your files',
                          textAlign: TextAlign.center,
                          style: messageStyle ??
                              TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                ],
              ),
            ),
          ),
        ),
        if (dismissable)
          Positioned(
            child: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.red,
              ),
              iconSize: 20,
              onPressed: onDismmisTap,
            ),
            right: 0,
            top: 0,
          ),
      ],
    );
  }
}
