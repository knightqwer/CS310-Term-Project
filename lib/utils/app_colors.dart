import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool _isDark = true;

  static void update(bool isDarkMode) {
    _isDark = isDarkMode;
  }

  static Color get background => _isDark ? Colors.black : const Color(0xFFF5F5F5);
  static Color get surface => _isDark ? const Color(0xFF212121) : Colors.white;
  static Color get primary => _isDark ? Colors.white : Colors.black;
  static Color get onPrimary => _isDark ? Colors.black : Colors.white;
  static Color get textPrimary => _isDark ? Colors.white : const Color(0xFF212121);
  static Color get textSecondary => _isDark ? Colors.grey[400]! : Colors.grey[600]!;
  static Color get textHint => Colors.grey[500]!;
  static Color get border => _isDark ? Colors.grey[700]! : Colors.grey[300]!;
  static Color get divider => _isDark ? Colors.grey[800]! : Colors.grey[200]!;
  static const Color error = Colors.red;
  static const Color success = Colors.green;
}
