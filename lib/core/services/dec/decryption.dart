import '../../../meta/extensions/logger.ext.dart';
import 'package:encrypt/encrypt.dart' as crypt;

import '../helper.service.dart';

class Decryption {
  final AppLogger _logger = AppLogger('Decryption');
  static final Decryption _singleton = Decryption._internal();
  Decryption._internal();
  factory Decryption.getInstance() => _singleton;

  /// Decrypts the value and returns the encrypted value
  String decryptValue(String token, String encryptedString) {
    _logger.finer('Fetching crypt keys');
    crypt.Key key = crypt.Key.fromUtf8(padCryptionKey(token)!);
    crypt.IV iv = crypt.IV.fromLength(16);
    crypt.Encrypter encrypter = crypt.Encrypter(crypt.AES(key));
    String decryptValue = encrypter.decrypt64(encryptedString, iv: iv);
    _logger.finer('Data decrypted successfully');
    return decryptValue;
  }
}
