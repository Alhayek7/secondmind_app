import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============ Colors based on DESIGN.md ============
  static const Color primary = Color(0xFF4A6458);      // Sage Green
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF98B4A6);
  static const Color onPrimaryContainer = Color(0xFF2D463C);
  
  static const Color secondary = Color(0xFF575F6A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD8E0ED);
  static const Color onSecondaryContainer = Color(0xFF5B636E);
  
  static const Color tertiary = Color(0xFF6C5485);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBEA3DA);
  static const Color onTertiaryContainer = Color(0xFF4E3766);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color surface = Color(0xFFF9FAF6);
  static const Color onSurface = Color(0xFF1A1C1A);
  static const Color surfaceContainerHighest = Color(0xFFE2E3DF);
  static const Color onSurfaceVariant = Color(0xFF424844);
  
  static const Color outline = Color(0xFF727974);
  static const Color outlineVariant = Color(0xFFC2C8C3);
  
  static const Color background = Color(0xFFF9FAF6);
  static const Color onBackground = Color(0xFF1A1C1A);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F0);
  static const Color surfaceContainer = Color(0xFFEDEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E5);
  
  // Status colors
  static const Color statusNew = primary;
  static const Color statusInProgress = secondary;
  static const Color statusCompleted = Color(0xFF2ECC71);
  static const Color statusUrgent = error;
  
  // ============ Typography ============
  static TextStyle get headlineXl => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.02,
    color: onSurface,
  );
  
  static TextStyle get headlineLg => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -0.01,
    color: onSurface,
  );
  
  static TextStyle get headlineLgMobile => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: onSurface,
  );
  
  static TextStyle get headlineMd => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: onSurface,
  );
  
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: onSurface,
  );
  
  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: onSurfaceVariant,
  );
  
  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.05,
    color: onSurfaceVariant,
  );
  
  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
    color: outline,
  );
  
  // ============ Shadows (Neumorphism-lite) ============
  static List<BoxShadow> get neumorphicShadow => [
    BoxShadow(
      offset: const Offset(8, 8),
      blurRadius: 16,
      color: Colors.grey.shade300.withValues(alpha: 0.5),
    ),
    BoxShadow(
      offset: const Offset(-4, -4),
      blurRadius: 12,
      color: Colors.white.withValues(alpha: 0.8),
    ),
  ];
  
  static List<BoxShadow> get neumorphicPressed => [
    BoxShadow(
      offset: const Offset(4, 4),
      blurRadius: 8,
      color: Colors.grey.shade300.withValues(alpha: 0.5),
    ),
  ];
  
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      offset: const Offset(0, 4),
      blurRadius: 12,
      color: Colors.black.withValues(alpha: 0.05),
    ),
  ];
  
  // ============ Theme Data ============
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
      ),
      
      fontFamily: GoogleFonts.inter().fontFamily,
      
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.9),
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineLgMobile,
        iconTheme: const IconThemeData(color: primary),
        surfaceTintColor: Colors.transparent,
      ),
      
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surfaceContainerLowest,
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: bodyMd.copyWith(color: outline),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: headlineMd,
          elevation: 2,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: bodyMd,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: primary,
        size: 24,
      ),
      
      dividerTheme: const DividerThemeData(
        color: outlineVariant,
        thickness: 0.5,
        space: 1,
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.9),
        selectedItemColor: primary,
        unselectedItemColor: outline,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: labelMd,
        unselectedLabelStyle: labelMd,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    // Dark theme implementation (will be added later)
    return lightTheme;
  }
}