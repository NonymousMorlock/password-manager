// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../models/qr.model.dart';

class NewUser extends ChangeNotifier {
  Map<String, dynamic> _atSignWithImgData = <String, dynamic>{};

  /// getter for atSignWithImgData
  Map<String, dynamic> get atSignWithImgData => _atSignWithImgData;

  /// setter for atSignWithImgData
  set atSignWithImgData(Map<String, dynamic> value) {
    _atSignWithImgData = value;
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
    _qrAtSign = value.atSign;
    _cramSecret = value.cramSecret;
    notifyListeners();
  }
}
