// 🌎 Project imports:
import '../../core/services/passman.env.dart';
import '../../meta/models/key.model.dart';
import '../../meta/models/value.model.dart';

class Keys {
  /// Profile picture key
  static final PassKey profilePicKey = PassKey()
    ..key = 'profilepic'
    ..namespace = PassmanEnv.appNamespace
    ..ttl = 0
    ..ttl = 0
    ..createdDate = DateTime.now()
    ..isBinary = false
    ..isPublic = true
    ..namespaceAware = true;

  /// User name key
  static final PassKey nameKey = PassKey(
    key: 'name',
    isPublic: true,
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
}
