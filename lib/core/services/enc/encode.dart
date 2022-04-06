// 🎯 Dart imports:
import 'dart:typed_data';

// 📦 Package imports:
import 'package:image/image.dart' as imglib;

// 🌎 Project imports:
import '../../../meta/extensions/logger.ext.dart';
import '../helper.service.dart';
import 'encryption.dart';

class Encode {
  final AppLogger _logger = AppLogger('Encode');
  static final Encode _singleton = Encode._internal();
  Encode._internal();
  factory Encode.getInstance() => _singleton;

  Encryption encryption = Encryption.getInstance();

  int _getEncoderCapacity(Uint16List img) => img.length;

  int? _encodeOnePixel(int pixel, int msg) {
    if (msg != 1 && msg != 0) {
      _logger.severe('Message encode bit is more than 1 bit');
      return null;
    }
    int lastBitMask = 254;
    int encoded = (pixel & lastBitMask) | msg;
    return encoded;
  }

  Future<Uint8List?> encodeImage(
      {required imglib.Image image,
      required String content,
      String? key}) async {
    _logger.finer('Image encoding started');
    Uint16List _img = Uint16List.fromList(image.getBytes().toList());
    String msg = content;
    if (key != null) {
      msg = encryption.encryptValue(key, msg);
    } else {
      _logger.warning('Encryption key not provided');
    }
    Uint16List encodedImg = _img;
    if (_getEncoderCapacity(_img) < getMsgSize(msg)) {
      _logger.severe('Message is too large to encode in image');
      return null;
    }

    /// *encoding the message
    Uint16List expandedMsg = expandMessage(msg2bytes(msg));
    Uint16List paddedMsg = padMessage(_getEncoderCapacity(_img), expandedMsg);

    if (paddedMsg.length != _getEncoderCapacity(_img)) {
      _logger.severe('Padded message and image capacity do not match');
      return null;
    }
    for (int i = 0; i < _getEncoderCapacity(_img); ++i) {
      encodedImg[i] = _encodeOnePixel(_img[i], paddedMsg[i])!;
    }
    return Uint8List.fromList(
      imglib.encodePng(
        imglib.Image.fromBytes(
          image.width,
          image.height,
          encodedImg.toList(),
        ),
      ),
    );
  }
}
