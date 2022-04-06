// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';

// 🌎 Project imports:
import '../extensions/logger.ext.dart';

class UserData extends ChangeNotifier {
  final AppLogger _logger = AppLogger('UserData');

  /// Onboarding preferences
  AtClientPreference _atOnboardingPreference = AtClientPreference();

  /// Get onboarding preferences
  AtClientPreference get atOnboardingPreference => _atOnboardingPreference;

  /// Set onboarding preferences
  set atOnboardingPreference(AtClientPreference value) {
    _logger.finer('Setting onboarding preferences...');
    _atOnboardingPreference = value;
    notifyListeners();
  }

  bool _networkConnected = false;
  bool get networkConnected => _networkConnected;
  set networkConnected(bool value) {
    _networkConnected = value;
    notifyListeners();
  }

  /// Current @sign
  String? _currentAtSign;

  /// Get current @sign
  String get currentAtSign => _currentAtSign!;

  /// Set current @sign
  set currentAtSign(String value) {
    _logger.finer('Setting current @sign to $value');
    _currentAtSign = value;
    notifyListeners();
  }

  /// Current ProfilePic
  Uint8List _currentProfilePic = Uint8List(0);

  /// Get current ProfilePic
  Uint8List get currentProfilePic => _currentProfilePic;

  /// Set current ProfilePic
  set currentProfilePic(Uint8List value) {
    _logger.finer('Setting current profile pic');
    _currentProfilePic = value;
    notifyListeners();
  }

  /// Master image
  Uint8List _masterImage = Uint8List(0);

  /// Get master image
  Uint8List get masterImage => _masterImage;

  /// Set master image
  set masterImage(Uint8List value) {
    _logger.finer('Setting current profile pic');
    _masterImage = value;
    notifyListeners();
  }

  /// Sync status
  SyncStatus _syncStatus = SyncStatus.notStarted;

  /// Get the sync status
  SyncStatus get syncStatus => _syncStatus;

  ///  Sets the sync status
  set setSyncStatus(SyncStatus isSyncing) {
    _logger.finer('Setting current sync status to ${isSyncing.name}');
    _syncStatus = isSyncing;
    notifyListeners();
  }
}
