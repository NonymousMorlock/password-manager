// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../app/constants/theme.dart';

class AppThemeNotifier extends ChangeNotifier {
  bool _darkTheme = false;
  Color _primaryColor = AppTheme.primary;

  ThemeData get currentTheme => _darkTheme
      ? AppTheme.darkTheme.copyWith(primaryColor: _primaryColor)
      : AppTheme.lightTheme.copyWith(primaryColor: _primaryColor);

  bool get isDarkTheme => _darkTheme;
  set isDarkTheme(bool isDark) {
    _darkTheme = isDark;
    notifyListeners();
  }

  Color get primary => _primaryColor;
  set primary(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void resetTheme() {
    _darkTheme = false;
    _primaryColor = AppTheme.primary;
    notifyListeners();
  }
}
