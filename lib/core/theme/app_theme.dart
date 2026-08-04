import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// NexLedger Super Modern Enterprise ERP Theme System.
/// Uses tailored Slate (#0F172A), Indigo (#4F46E5), and Emerald (#10B981) palette.
class AppTheme {
  AppTheme._();

  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryDarkSlate = Color(0xFF0F172A);
  static const Color surfaceBg = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      primary: primaryIndigo,
      surface: cardBg,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceBg,
      fontFamily: 'Roboto',

      // AppBar
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

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        color: cardBg,
        margin: EdgeInsets.zero,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: primaryIndigo, width: 1.8),
        ),
        filled: true,
        fillColor: cardBg,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        isDense: true,
        labelStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),

      // Data tables
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: textMain,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
        dataTextStyle: const TextStyle(
          fontSize: 13,
          color: textMain,
          fontWeight: FontWeight.w500,
        ),
        dividerThickness: 1,
        columnSpacing: 24,
        horizontalMargin: 16,
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
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
