import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF4A8958);
  static const Color darkGreen = Color(0xFF294C32);
  static const Color mediumGreen = Color(0xFF679B70);

  static const Color softGreen = Color(0xFFE8F2E8);
  static const Color paleGreen = Color(0xFFF1F7F0);

  static const Color background = Color(0xFFF8F8F1);

  static const Color textDark = Color(0xFF26382B);
  static const Color textMedium = Color(0xFF69766C);
  static const Color textLight = Color(0xFF929A94);

  static const Color white = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFE19A3E);
  static const Color warningBackground = Color(0xFFFFF4E2);

  static const Color success = Color(0xFF4A8958);
  static const Color successBackground = Color(0xFFE8F3E8);

  // ============================================================
  // MAIN THEME
  // ============================================================

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryGreen,
      onPrimary: white,
      secondary: mediumGreen,
      surface: background,
      onSurface: textDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),

      iconTheme: IconThemeData(
        color: textDark,
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFDFDF8),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 70,

      indicatorColor: softGreen,

      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: darkGreen,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            );
          }

          return const TextStyle(
            color: textMedium,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          );
        },
      ),

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: primaryGreen,
              size: 21,
            );
          }

          return const IconThemeData(
            color: textMedium,
            size: 20,
          );
        },
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFCFCF8),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.3,
        ),
      ),

      labelStyle: const TextStyle(
        color: textMedium,
        fontSize: 13,
      ),

      floatingLabelStyle: const TextStyle(
        color: primaryGreen,
        fontWeight: FontWeight.w600,
      ),

      prefixIconColor: textMedium,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 0,

        minimumSize: const Size(
          double.infinity,
          52,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    floatingActionButtonTheme:
        const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: white,
      elevation: 5,

      shape: CircleBorder(),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,

      backgroundColor: darkGreen,

      elevation: 6,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      contentTextStyle: const TextStyle(
        color: white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFFFBFBF7),
      surfaceTintColor: Colors.transparent,
      elevation: 10,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),
  );
}