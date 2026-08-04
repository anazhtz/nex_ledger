import 'package:flutter/material.dart';

/// NexLedger Material 3 light theme.
/// Uses a professional blue-slate seed for a corporate/finance aesthetic.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF2563EB); // Tailwind blue-600

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        indicatorColor: colorScheme.primaryContainer,
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
        margin: const EdgeInsets.all(0),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),

      // Data tables
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          colorScheme.surfaceContainerLow,
        ),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontSize: 13,
        ),
        dataTextStyle: const TextStyle(fontSize: 13),
        dividerThickness: 1,
        columnSpacing: 24,
        horizontalMargin: 16,
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Filled button (same as elevated for consistency)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
