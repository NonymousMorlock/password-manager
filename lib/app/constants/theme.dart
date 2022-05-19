// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  /// App primary color
  static MaterialColor primary = Colors.green;

  /// Disabled content color
  static Color disabled = const Color(0xFF464646);

  static MaterialColor grey = Colors.grey;

  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: Colors.white,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primary,
      splashColor: Colors.transparent,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      color: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: Colors.black,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    hoverColor: Colors.transparent,
    canvasColor: Colors.transparent,
    focusColor: Colors.transparent,
    primaryColor: Colors.green,
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF272C35),
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    bottomSheetTheme: const BottomSheetThemeData(
      modalBackgroundColor: Color(0xFF272C35),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: primary,
      splashColor: Colors.transparent,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    splashColor: Colors.transparent,
    hoverColor: Colors.transparent,
    canvasColor: Colors.transparent,
    focusColor: Colors.transparent,
    primaryColor: Colors.green,
  );
}
