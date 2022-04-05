// 🐦 Flutter imports:
import 'dart:typed_data';

import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';

class UserData extends ChangeNotifier {
  AtClientPreference _atOnboardingPreference = AtClientPreference();

  /// getter for atOnboardingPreference
  AtClientPreference get atOnboardingPreference => _atOnboardingPreference;

  /// setter for atOnboardingPreference
  set atOnboardingPreference(AtClientPreference value) {
    _atOnboardingPreference = value;
    notifyListeners();
  }

  String? _currentAtSign;
  String get currentAtSign => _currentAtSign!;
  set currentAtSign(String value) {
    _currentAtSign = value;
    notifyListeners();
  }

  Uint8List? _currentProfilePic;
  Uint8List get currentProfilePic => _currentProfilePic!;
  set currentProfilePic(Uint8List value) {
    _currentProfilePic = value;
    notifyListeners();
  }

  /// Sync status
  SyncStatus _syncStatus = SyncStatus.notStarted;

  /// Get the sync status
  SyncStatus get syncStatus => _syncStatus;

  ///  Sets the sync status
  set setSyncStatus(SyncStatus isSyncing) {
    _syncStatus = isSyncing;
    notifyListeners();
  }
}
