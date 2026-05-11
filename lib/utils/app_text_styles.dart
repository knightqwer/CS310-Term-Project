import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headline => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get title => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get subtitle => GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: 14,
      );

  static TextStyle get body => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 15,
      );

  static TextStyle get bodySecondary => GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontSize: 13,
      );

  static TextStyle get button => GoogleFonts.poppins(
        color: AppColors.onPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get stat => GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get error => GoogleFonts.poppins(
        color: AppColors.error,
        fontSize: 12,
      );
}
