// 🌎 Project imports:
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';

class Keys {
  /// Profile picture key
  static final PassKey profilePicKey = PassKey(
    key: 'profilepic',
    isPublic: false,
    isHidden: true,
    value: Value(
      isHidden: true,
      labelName: 'Profile pic',
    ),
  );

  /// User name key
  static final PassKey nameKey = PassKey(
    key: 'name',
    isPublic: false,
    isHidden: true,
    value: Value(
      labelName: 'Username',
      isHidden: true,
    ),
  );

  /// Master image key
  static final PassKey masterImgKey = PassKey(
    key: 'masterpassimg',
    isPublic: false,
    isHidden: true,
    value: Value(
      labelName: 'Master password image',
      isHidden: true,
    ),
  );

  /// Password key
  static final PassKey passwordKey = PassKey(
    isPublic: false,
    isHidden: true,
    value: Value(
      labelName: 'Password',
      isHidden: true,
    ),
  );

  /// Cards key
  static final PassKey cardsKey = PassKey(
    isPublic: false,
    isHidden: true,
    value: Value(
      labelName: 'Cards',
      isHidden: true,
    ),
  );

  /// Images key
  static final PassKey imagesKey = PassKey(
    isPublic: false,
    isHidden: true,
    value: Value(
      labelName: 'Images',
      isHidden: true,
    ),
  );

  /// Fingerprint key
  static final PassKey fingerprintKey = PassKey(
    isPublic: false,
    key: 'fingerprint',
    isHidden: true,
    value: Value(
      labelName: 'Fingerprint',
      isHidden: true,
    ),
  );
}
