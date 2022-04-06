// 📦 Package imports:
import 'package:encrypt/encrypt.dart' as crypto;

// 🌎 Project imports:
import '../../../meta/extensions/logger.ext.dart';
import '../helper.service.dart';

class Encryption {
  final AppLogger _logger = AppLogger('Encryption');
  static final Encryption _singleton = Encryption._internal();
  Encryption._internal();
  factory Encryption.getInstance() => _singleton;

  /// Encrypts the value and returns the encrypted value
  String encryptValue(String token, String msg) {
    _logger.finer('Fetching crypt keys');
    crypto.Key key = crypto.Key.fromUtf8(padCryptionKey(token)!);
    crypto.IV iv = crypto.IV.fromLength(16);
    crypto.Encrypter encrypter = crypto.Encrypter(crypto.AES(key));
    crypto.Encrypted encrypted = encrypter.encrypt(msg, iv: iv);
    msg = encrypted.base64;
    _logger.finer('Data encrypted successfully');
    return msg;
  }
}
