// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../extensions/logger.ext.dart';
import '../models/qr.model.dart';

class NewUser extends ChangeNotifier {
  final AppLogger _logger = AppLogger('NewUser');

  /// New user data as a map
  Map<String, dynamic> _newUserData = <String, dynamic>{};

  /// Get new user data as a map
  Map<String, dynamic> get newUserData => _newUserData;

  /// Set new user data as a map
  set newUserData(Map<String, dynamic> value) {
    _logger.finer('Updating new user data with ${json.encode(value)}');
    _newUserData = value;
    notifyListeners();
  }

  /// @sign from Qr Code
  late String _qrAtSign;

  /// CRAM secret from Qr Code
  late String _cramSecret;

  /// Getter for the [QrModel].
  QrModel get getQrData => QrModel(atSign: _qrAtSign, cramSecret: _cramSecret);

  /// Setter for the [QrModel].
  set setQrData(QrModel value) {
    _logger.finer('Setting QrCode model for ${value.atSign}');
    _qrAtSign = value.atSign;
    _cramSecret = value.cramSecret;
    notifyListeners();
  }
}
