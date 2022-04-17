// 🎯 Dart imports:
import 'dart:typed_data';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:at_client_mobile/at_client_mobile.dart';

// 🌎 Project imports:
import '../extensions/logger.ext.dart';
import '../models/freezed/card.model.dart';
import '../models/freezed/image.model.dart';
import '../models/freezed/password.model.dart';

class UserData extends ChangeNotifier {
  final AppLogger _logger = AppLogger('UserData');

  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  set isAdmin(bool value) {
    _logger.finer('isAdmin: $value');
    _isAdmin = value;
    notifyListeners();
  }

  bool _authenticated = false;

  bool get authenticated => _authenticated;

  set authenticated(bool _auth) {
    _logger.finer('Setting user auth status to $_auth');
    _authenticated = _auth;
    notifyListeners();
  }

  bool _fingerprintAuthEnabled = false;

  bool get fingerprintAuthEnabled => _fingerprintAuthEnabled;

  set fingerprintAuthEnabled(bool _auth) {
    _logger.finer('Setting fingerprint auth status to $_auth');
    _fingerprintAuthEnabled = _auth;
    notifyListeners();
  }

  String? _userName;

  String? get userName => _userName;

  set userName(String? value) {
    _logger.finer('Setting userName to $value');
    _userName = value;
    notifyListeners();
  }

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

  String? _name;

  String get name => _name!;

  set name(String value) {
    _logger.finer('Setting current @sign name to $value');
    _name = value;
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

  /// List of passwords
  List<Password> _passwords = <Password>[];

  /// Get the list of passwords
  List<Password> get passwords => _passwords;

  /// Set the list of passwords
  set passwords(List<Password> value) {
    _logger.finer('Total passwords : ${value.length}');
    _passwords = value;
    notifyListeners();
  }

  /// List of passwords
  List<CardModel> _cards = <CardModel>[];

  /// Get the list of passwords
  List<CardModel> get cards => _cards;

  /// Set the list of passwords
  set cards(List<CardModel> value) {
    _logger.finer('Total cards: ${value.length}');
    _cards = value;
    notifyListeners();
  }

  /// List of images
  List<Images> _images = <Images>[];

  /// Get the list of images
  List<Images> get images => _images;

  /// Set the list of images
  set images(List<Images> value) {
    _logger.finer('Total images: ${value.length}');
    _images = value;
    notifyListeners();
  }
}
