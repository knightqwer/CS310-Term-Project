import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'isDarkMode';
  final SharedPreferences _prefs;
  bool _isDarkMode;

  ThemeProvider(this._prefs) : _isDarkMode = _prefs.getBool(_key) ?? true {
    AppColors.update(_isDarkMode);
  }

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _prefs.setBool(_key, value);
    AppColors.update(value);
    notifyListeners();
  }

  void toggle() => setDarkMode(!_isDarkMode);
}
