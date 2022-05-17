import 'package:flutter/material.dart';

import '../../app/constants/theme.dart';

class AppThemeNotifier extends ChangeNotifier {
  bool _darkTheme = false;
  ThemeData get currentTheme =>
      _darkTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
  bool get isDarkTheme => _darkTheme;
  set isDarkTheme(bool isDark) {
    _darkTheme = isDark;
    notifyListeners();
  }
}
