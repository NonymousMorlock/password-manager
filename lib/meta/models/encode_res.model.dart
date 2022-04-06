// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:image/image.dart' as imglib;

class EncodeResponse {
  EncodeResponse({
    required this.editableImage,
    required this.displayableImage,
    required this.data,
  });
  imglib.Image editableImage;
  Image displayableImage;
  Uint8List data;
}
