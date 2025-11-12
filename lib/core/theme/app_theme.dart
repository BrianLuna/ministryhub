import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matisse color palette
class AppColors {
  // Matisse palette
  static const Color matisse50 = Color(0xFFF2F8FD);
  static const Color matisse100 = Color(0xFFE5F0F9);
  static const Color matisse200 = Color(0xFFC5E0F2);
  static const Color matisse300 = Color(0xFF91C7E8);
  static const Color matisse400 = Color(0xFF56A9DA);
  static const Color matisse500 = Color(0xFF318FC6);
  static const Color matisse600 = Color(0xFF2172A8);
  static const Color matisse700 = Color(0xFF1F6597);
  static const Color matisse800 = Color(0xFF1B4E71);
  static const Color matisse900 = Color(0xFF1B425F);
  static const Color matisse950 = Color(0xFF122A3F);

  // Neutral colors for light theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  // Neutral colors for dark theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
}

/// Application theme configuration
class AppTheme {
  /// Helper method to get DM Sans font
  static TextStyle _dmSans({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.matisse600,
        onPrimary: Colors.white,
        secondary: AppColors.matisse400,
        onSecondary: Colors.white,
        tertiary: AppColors.matisse300,
        onTertiary: AppColors.matisse900,
        error: Colors.red.shade700,
        onError: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.matisse100,
        onSurfaceVariant: AppColors.matisse800,
        outline: AppColors.matisse300,
        outlineVariant: AppColors.matisse200,
        shadow: Colors.black.withValues(alpha: 0.1),
        scrim: Colors.black.withValues(alpha: 0.5),
        inverseSurface: AppColors.darkSurface,
        onInverseSurface: AppColors.darkOnSurface,
        inversePrimary: AppColors.matisse400,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.matisse200,
      textTheme: _textTheme(Colors.black87),
      primaryTextTheme: _textTheme(Colors.white),
      iconTheme: const IconThemeData(color: AppColors.matisse700, size: 24),
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.matisse600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.matisse600,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.matisse600,
          side: const BorderSide(color: AppColors.matisse600, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.matisse600,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.matisse50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
        labelStyle: _dmSans(color: AppColors.matisse700, fontSize: 14),
        hintStyle: _dmSans(color: AppColors.matisse400, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.matisse600,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.matisse600,
        unselectedItemColor: AppColors.matisse400,
        selectedLabelStyle: _dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _dmSans(fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.matisse100,
        selectedColor: AppColors.matisse600,
        labelStyle: _dmSans(fontSize: 14, color: AppColors.matisse800),
        secondaryLabelStyle: _dmSans(fontSize: 14, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.matisse400,
        onPrimary: AppColors.matisse950,
        secondary: AppColors.matisse500,
        onSecondary: Colors.white,
        tertiary: AppColors.matisse300,
        onTertiary: AppColors.matisse950,
        error: Colors.red.shade400,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.matisse900,
        onSurfaceVariant: AppColors.matisse200,
        outline: AppColors.matisse700,
        outlineVariant: AppColors.matisse800,
        shadow: Colors.black.withValues(alpha: 0.3),
        scrim: Colors.black.withValues(alpha: 0.7),
        inverseSurface: AppColors.lightSurface,
        onInverseSurface: AppColors.lightOnSurface,
        inversePrimary: AppColors.matisse600,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.matisse800,
      textTheme: _textTheme(Colors.white.withValues(alpha: 0.87)),
      primaryTextTheme: _textTheme(AppColors.matisse950),
      iconTheme: const IconThemeData(color: AppColors.matisse300, size: 24),
      primaryIconTheme: const IconThemeData(
        color: AppColors.matisse950,
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.matisse900,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _dmSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.matisse500,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.matisse400,
          side: const BorderSide(color: AppColors.matisse400, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.matisse400,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: _dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.matisse900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.matisse400, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        labelStyle: _dmSans(color: AppColors.matisse300, fontSize: 14),
        hintStyle: _dmSans(color: AppColors.matisse500, fontSize: 14),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.matisse500,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.matisse400,
        unselectedItemColor: AppColors.matisse600,
        selectedLabelStyle: _dmSans(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: _dmSans(fontSize: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.matisse900,
        selectedColor: AppColors.matisse500,
        labelStyle: _dmSans(fontSize: 14, color: AppColors.matisse200),
        secondaryLabelStyle: _dmSans(fontSize: 14, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Text theme with DM Sans font
  static TextTheme _textTheme(Color defaultColor) {
    return TextTheme(
      displayLarge: _dmSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: defaultColor,
      ),
      displayMedium: _dmSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: defaultColor,
      ),
      displaySmall: _dmSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: defaultColor,
      ),
      headlineLarge: _dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: defaultColor,
      ),
      headlineMedium: _dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: defaultColor,
      ),
      headlineSmall: _dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: defaultColor,
      ),
      titleLarge: _dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: defaultColor,
      ),
      titleMedium: _dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: defaultColor,
      ),
      titleSmall: _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: defaultColor,
      ),
      bodyLarge: _dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: defaultColor,
      ),
      bodyMedium: _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: defaultColor,
      ),
      bodySmall: _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: defaultColor,
      ),
      labelLarge: _dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: defaultColor,
      ),
      labelMedium: _dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: defaultColor,
      ),
      labelSmall: _dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: defaultColor,
      ),
    );
  }
}
