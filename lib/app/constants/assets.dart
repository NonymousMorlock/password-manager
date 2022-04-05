// 🎯 Dart imports:
import 'dart:math';

class Assets {
  /// All assets base path
  static const String _assetsBasePath = 'assets';

  /// All images base path
  static const String _imgBasePath = '$_assetsBasePath/images';

  /// All lottie base path
  static const String _lottieBasePath = '$_assetsBasePath/lottie';

  /// All avatars base path
  static const String _avatarsBasePath = '$_assetsBasePath/avatars';

  static const String configFile = '$_assetsBasePath/config/env.yaml';

  static const String logo = '$_lottieBasePath/logo.json';
  static const String logoImg = '$_imgBasePath/logo.png';

  static const String error = '$_imgBasePath/error.png';

  static const String atLogo = '$_imgBasePath/@.png';
  static const String atKeys = '$_imgBasePath/atKeys.png';
  static const String dashboardQR = '$_imgBasePath/dashboard_qr.png';

  static const String alien = '$_avatarsBasePath/alien.png';
  static const String bear = '$_avatarsBasePath/bear.png';
  static const String cat = '$_avatarsBasePath/cat.png';
  static const String cow = '$_avatarsBasePath/cow.png';
  static const String dog = '$_avatarsBasePath/dog.png';
  static const String fox = '$_avatarsBasePath/fox.png';
  static const String frog = '$_avatarsBasePath/frog.png';
  static const String ghost = '$_avatarsBasePath/ghost.png';
  static const String kola = '$_avatarsBasePath/kola.png';
  static const String lion = '$_avatarsBasePath/lion.png';
  static const String monkey = '$_avatarsBasePath/monkey.png';
  static const String octopus = '$_avatarsBasePath/octopus.png';
  static const String owl = '$_avatarsBasePath/owl.png';
  static const String panda = '$_avatarsBasePath/panda.png';
  static const String pig = '$_avatarsBasePath/pig.png';
  static const String rabbit = '$_avatarsBasePath/rabbit.png';
  static const String rat = '$_avatarsBasePath/rat.png';
  static const String shark = '$_avatarsBasePath/shark.png';
  static const String tiger = '$_avatarsBasePath/tiger.png';

  static final List<String> avatars = <String>[
    alien,
    bear,
    cat,
    cow,
    dog,
    fox,
    frog,
    ghost,
    kola,
    lion,
    monkey,
    octopus,
    owl,
    panda,
    pig,
    rabbit,
    rat,
    shark,
    tiger,
  ];
  static String getRandomAvatar() => avatars[Random().nextInt(avatars.length)];
}
