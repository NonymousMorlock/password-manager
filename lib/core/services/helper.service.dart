// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import '../../meta/extensions/logger.ext.dart';
import '../../meta/notifiers/theme.dart';

final AppLogger _logger = AppLogger('Helper services');

/// Padding an Crypto key to 32 bytes
String? padCryptionKey(String key) {
  _logger.finer('Padding cryption key.');
  if (key.length > 32) {
    _logger.severe('Cryption key length greater than 32');
    return null;
  }
  String paddedKey = key;
  int padCount = 32 - key.length;
  for (int i = 0; i < padCount; ++i) {
    paddedKey += '.';
  }
  _logger.finer('Padding cryption key successfully.');
  return paddedKey;
}

Uint16List padToBytes(Uint16List msg) {
  int padSize = dataLength - msg.length % dataLength;
  Uint16List padded = Uint16List(msg.length + padSize);
  for (int i = 0; i < msg.length; ++i) {
    padded[i] = msg[i];
  }
  for (int i = 0; i < padSize; ++i) {
    padded[msg.length + i] = 0;
  }
  return padded;
}

Uint16List padMessage(int capacity, Uint16List msg) {
  Uint16List padded = Uint16List(capacity);
  for (int i = 0; i < msg.length; ++i) {
    padded[i] = msg[i];
  }
  return padded;
}

Future<Uint8List> loadAsset(String assetName) async {
  ByteData bytes = await rootBundle.load(assetName);
  Uint8List data = bytes.buffer.asUint8List();
  return data;
}

const int byteSize = 8;
const int byteCount = 2;
const int dataLength = byteSize * byteCount;

/// !Helper function to convert string to bytes
Uint16List msg2bytes(String msg) => Uint16List.fromList(msg.codeUnits);

String bytes2msg(Uint16List bytes) => String.fromCharCodes(bytes);

int getMsgSize(String msg) {
  Uint16List byteMsg = msg2bytes(msg);
  return byteMsg.length * dataLength;
}

/// * Helper function to expand byte messages to bit messages
Uint16List expandMessage(Uint16List msg) {
  Uint16List expanded = Uint16List(msg.length * dataLength);
  for (int i = 0; i < msg.length; ++i) {
    int msgByte = msg[i];
    for (int j = 0; j < dataLength; ++j) {
      int lastBit = msgByte & 1;
      expanded[i * dataLength + (dataLength - j - 1)] = lastBit;
      msgByte = msgByte >> 1;
    }
  }
  return expanded;
}

Color iconThemedColor(BuildContext context, Color color) =>
    context.watch<AppThemeNotifier>().isDarkTheme
        ? color.withOpacity(0.8)
        : color;
