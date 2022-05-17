// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class AppTheme {
  /// App primary color
  static MaterialColor primary = Colors.green;

  /// Disabled content color
  static MaterialColor disabled = Colors.grey;

  static MaterialColor grey = Colors.grey;

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    hoverColor: Colors.transparent,
    canvasColor: Colors.transparent,
    focusColor: Colors.transparent,
    primaryColor: Colors.green,
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF272c35),
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    canvasColor: Colors.transparent,
    focusColor: Colors.transparent,
    primaryColor: Colors.lightGreen,
  );
}
