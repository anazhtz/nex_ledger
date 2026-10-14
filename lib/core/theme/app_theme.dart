import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// NexLedger ERP theme: navy sidebar, white form panels, blue accents and
/// compact, dense inputs in the style of classic desktop ERP software.
class AppTheme {
  AppTheme._();

  // Brand
  static const Color primaryBlue = Color(0xFF1F5FBF);
  static const Color navy = Color(0xFF12284C);
  static const Color navyDeep = Color(0xFF0D1E3A);
  static const Color navyActive = Color(0xFF3566B0);
  static const Color successGreen = Color(0xFF2E9B47);
  static const Color dangerRed = Color(0xFFD93025);

  // Surfaces
  static const Color surfaceBg = Color(0xFFF1F4F9);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFD5DCE8);
  static const Color tableHeaderBg = Color(0xFFDDE8F6);
  static const Color totalsBg = Color(0xFFFFF9E6);
  static const Color totalsBorder = Color(0xFFEBDDA8);

  // Text
  static const Color textMain = Color(0xFF1B2433);
  static const Color textMuted = Color(0xFF5B6678);

  static const double radius = 4;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: cardBg,
      brightness: Brightness.light,
    );

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBg,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.compact,

      appBarTheme: const AppBarTheme(
        backgroundColor: cardBg,
        foregroundColor: textMain,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        color: cardBg,
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: border(borderColor),
        enabledBorder: border(borderColor),
        focusedBorder: border(primaryBlue, 1.5),
        errorBorder: border(dangerRed),
        focusedErrorBorder: border(dangerRed, 1.5),
        filled: true,
        fillColor: cardBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 11.h),
        isDense: true,
        labelStyle: const TextStyle(
            color: textMuted, fontWeight: FontWeight.w500, fontSize: 13),
        hintStyle: const TextStyle(color: Color(0xFF9AA5B8), fontSize: 13),
        errorStyle: const TextStyle(fontSize: 11),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(tableHeaderBg),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textMain,
          fontSize: 12.5,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 13,
          color: textMain,
          fontWeight: FontWeight.w500,
        ),
        dividerThickness: 1,
        columnSpacing: 24,
        horizontalMargin: 14,
        headingRowHeight: 42,
        dataRowMinHeight: 40,
        dataRowMaxHeight: 52,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textMain,
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
