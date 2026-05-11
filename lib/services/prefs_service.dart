import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _darkModeKey = 'isDarkMode';

  final SharedPreferences _prefs;

  PrefsService(this._prefs);

  static Future<PrefsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PrefsService(prefs);
  }

  bool getDarkMode() => _prefs.getBool(_darkModeKey) ?? true;

  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);
}
