// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:dotted_border/dotted_border.dart';

class FileUploadSpace extends StatelessWidget {
  const FileUploadSpace({
    required this.onTap,
    this.uploadMessage,
    this.onDismmisTap,
    this.dismissable = false,
    this.assetPath,
    this.boxColor,
    Key? key,
    this.isUploading = false,
  }) : super(key: key);
  final GestureTapCallback? onTap;
  final VoidCallback? onDismmisTap;
  final String? uploadMessage;
  final String? assetPath;
  final Color? boxColor;
  final bool isUploading;
  final bool dismissable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: onTap,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const <double>[10, 10],
            strokeCap: StrokeCap.round,
            strokeWidth: 3,
            color: boxColor ?? Colors.green.shade400,
            child: Container(
              width: 300,
              height: 150,
              decoration: BoxDecoration(
                color: boxColor ?? Colors.green.withOpacity(.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          uploadMessage ?? 'Upload your files',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
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
