// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:page_transition/page_transition.dart';

PageTransition<Widget> pageTransition(RouteSettings settings, Widget screen) {
  return PageTransition<Widget>(
    child: screen,
    type: PageTransitionType.fade,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 100),
    settings: settings,
  );
}

/// Vertical spacer with presised height.
SizedBox vSpacer(double size) => SizedBox(width: 0, height: size);

/// Horizontal spacer with presised width.
SizedBox hSpacer(double size) => SizedBox(width: size, height: 0);

/// Square spacer with presised size.
SizedBox square(double size) => SizedBox(width: size, height: size);

/// Square spacer with presised size.
SizedBox squareWidget(double size, {Widget? child}) =>
    SizedBox(width: size, height: size, child: child);

/// boolean to check if the device is an android device.
bool get isAndroid => Platform.isAndroid;

/// boolean to check if the device is an iOS device.
bool get isIos => Platform.isIOS;

late String logFileLocation;

String get logPath => logFileLocation;

set logPath(String path) => logFileLocation = path;
