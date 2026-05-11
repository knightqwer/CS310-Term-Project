import 'package:flutter/material.dart';

class AppPaddings {
  AppPaddings._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets tile = EdgeInsets.symmetric(horizontal: md, vertical: 14);
  static const EdgeInsets chatList = EdgeInsets.symmetric(horizontal: 12, vertical: md);
}
