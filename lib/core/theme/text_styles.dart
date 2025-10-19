import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:svar_ai/core/constants/app_colors.dart';

class AppTextTheme {
  // ================================
  // HEADINGS — Red Hat Display
  // ================================
  static final TextStyle h1 = GoogleFonts.redHatDisplay(
    fontWeight: FontWeight.w600,
    fontSize: 40,
    color: AppColors.textBlack,
  );

  static final TextStyle h2 = GoogleFonts.redHatDisplay(
    fontWeight: FontWeight.w600,
    fontSize: 30,
    color: AppColors.textBlack,
  );

  static final TextStyle h3 = GoogleFonts.redHatDisplay(
    fontWeight: FontWeight.w500,
    letterSpacing: 0.01,
    fontSize: 25,
    height: 1.25,
    color: AppColors.textBlack,
  );

  static final TextStyle h4 = GoogleFonts.redHatDisplay(
    fontWeight: FontWeight.w600,
    fontSize: 18.5.sp,
    color: AppColors.textBlack,
  );

  static final TextStyle h5 = GoogleFonts.redHatDisplay(
    fontWeight: FontWeight.w500,
    fontSize: 16,
    color: AppColors.textBlack,
  );

  // ================================
  // BODY — Red Hat Text
  // ================================
  static final TextStyle button = GoogleFonts.redHatText(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: Colors.white,
  );

  static final TextStyle body1 = GoogleFonts.redHatText(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    letterSpacing: 0.01,
    height: 1.5,
    color: AppColors.textBlack,
  );

  static final TextStyle body1Medium = GoogleFonts.redHatText(
    fontWeight: FontWeight.w500,
    fontSize: 16.sp,
    letterSpacing: 0.01,
    color: AppColors.black,
  );

  static final TextStyle body2 = GoogleFonts.redHatText(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: AppColors.textBlack,
  );

  static final TextStyle body2Medium = GoogleFonts.redHatText(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.textBlack,
  );

  static final TextStyle body3 = GoogleFonts.redHatText(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.textBlack,
  );

  static final TextStyle body3Medium = GoogleFonts.redHatText(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.textBlack,
  );

  static final TextStyle caption = GoogleFonts.redHatText(
    fontWeight: FontWeight.w400,
    fontSize: 11,
    color: AppColors.grey500,
  );

  // ================================
  // THEME MAPPING
  // ================================
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: h1,
    displayMedium: h2,
    displaySmall: h3,
    headlineMedium: h4,
    headlineSmall: h5,
    bodyLarge: body1,
    bodyMedium: body2,
    bodySmall: body3,
    labelLarge: button,
  );
}
