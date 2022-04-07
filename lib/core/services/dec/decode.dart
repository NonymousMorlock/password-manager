import 'dart:typed_data';
import 'package:image/image.dart' as imglib;
import 'package:encrypt/encrypt.dart' as crypt;

import '../../../meta/extensions/logger.ext.dart';
import '../helper.service.dart';

class Decode {
  final AppLogger _logger = AppLogger('Decode');
  static final Decode _singleton = Decode._internal();
  Decode._internal();
  factory Decode.getInstance() => _singleton;

  String? decodeMessageFromImage(imglib.Image image, String token,
      {bool getRealData = false}) {
    try {
      _logger.finer('Decoding image started');
      List<int> bytes = image.getBytes().toList();
      Uint16List extractedBits =
          _extractBitsFromImg(Uint16List.fromList(bytes));
      Uint16List padded = padToBytes(extractedBits);
      Uint16List? byteMsg = _bits2bytes(padded);
      Uint16List sanitized = _sanitizePaddingZeros(byteMsg!);
      String msg = bytes2msg(sanitized);
      if (getRealData) {
        crypt.Key key = crypt.Key.fromUtf8(padCryptionKey(token)!);
        crypt.IV iv = crypt.IV.fromLength(16);
        crypt.Encrypter encrypter = crypt.Encrypter(crypt.AES(key));
        crypt.Encrypted encryptedMsg = crypt.Encrypted.fromBase64(msg);
        msg = encrypter.decrypt(encryptedMsg, iv: iv);
      }
      _logger.finer('Decoding image done');
      return msg;
    } on Exception {
      _logger.severe('Decoding image failed');
      return null;
    }
  }

  Uint16List _extractBitsFromImg(Uint16List img) {
    Uint16List extracted = Uint16List(img.length);
    for (int i = 0; i < img.length; i++) {
      extracted[i] = img[i] & 1;
    }
    return extracted;
  }

  Uint16List? _bits2bytes(Uint16List bits) {
    if ((bits.length % dataLength) != 0) {
      _logger.severe('Bits contain incomplete or invalid data');
      return null;
    }
    int byteCnt = bits.length ~/ dataLength;
    Uint16List byteMsg = Uint16List(byteCnt);
    for (int i = 0; i < byteCnt; ++i) {
      Uint16List bitsOfByte = Uint16List.fromList(
          bits.getRange(i * dataLength, i * dataLength + dataLength).toList());
      int? byte = assembleBits(bitsOfByte);
      if (byte == null) {
        return null;
      }
      byteMsg[i] = byte;
    }
    return byteMsg;
  }

  int? assembleBits(Uint16List byte) {
    if (byte.length != dataLength) {
      _logger.severe('byte_incorrect_size');
      return null;
    }
    int assembled = 0;
    for (int i = 0; i < dataLength; ++i) {
      if (byte[i] != 1 && byte[i] != 0) {
        _logger.severe('Bit is not 0 or 1');
        return null;
      }
      assembled = assembled << 1;
      assembled = assembled | byte[i];
    }
    return assembled;
  }

  Uint16List _sanitizePaddingZeros(Uint16List msg) {
    int lastNonZeroIdx = msg.length - 1;
    while (msg[lastNonZeroIdx] == 0) {
      --lastNonZeroIdx;
    }
    Uint16List sanitized =
        Uint16List.fromList(msg.getRange(0, lastNonZeroIdx + 1).toList());
    return sanitized;
  }
}
