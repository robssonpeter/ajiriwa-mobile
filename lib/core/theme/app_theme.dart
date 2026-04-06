import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme configuration based on Ajiriwa branding guidelines
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF10B981); // Emerald Green
  static const Color primaryDarkColor = Color(0xFF059669); // Dark variant
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFF6B7280);
  static const Color darkGray = Color(0xFF374151);

  // Spacing
  static const double spacing = 8.0;
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius
  static const double borderRadius = 8.0;
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusLarge = 12.0;

  // Elevation
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;

  /// Light theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.nunitoTextTheme(),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: white,
        primaryContainer: primaryColor.withOpacity(0.1),
        onPrimaryContainer: primaryDarkColor,
        secondary: primaryDarkColor,
        onSecondary: white,
        error: Colors.red.shade700,
        background: white,
        surface: white,
        onSurface: darkGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkGray,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: elevationSmall,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacing,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacing,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMedium,
            vertical: spacing,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.all(spacingMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: lightGray.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: lightGray.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.red.shade700),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.red.shade700, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: lightGray.withOpacity(0.2),
        thickness: 1,
        space: spacingMedium,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightGray,
        type: BottomNavigationBarType.fixed,
        elevation: elevationMedium,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: lightGray,
        indicatorColor: primaryColor,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        disabledColor: lightGray.withOpacity(0.1),
        selectedColor: primaryColor,
        secondarySelectedColor: primaryDarkColor,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing,
          vertical: spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        labelStyle: const TextStyle(color: darkGray),
        secondaryLabelStyle: const TextStyle(color: white),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
    );
  }

  /// Dark theme configuration (optional)
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        onPrimary: white,
        primaryContainer: primaryColor.withOpacity(0.2),
        onPrimaryContainer: white,
        secondary: primaryDarkColor,
        onSecondary: white,
        error: Colors.red.shade300,
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.grey.shade300,
      ),
      // Other theme configurations would be similar to light theme but adapted for dark mode
    );
  }
}
