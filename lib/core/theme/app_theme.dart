import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============ Colors ============
  static const Color primary = Color(0xFF4A6458);
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
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F0);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E5);
  
  static const Color statusCompleted = Color(0xFF2ECC71);
  static const Color statusPending = Color(0xFFF39C12);
  static const Color statusUrgent = Color(0xFFBA1A1A);
  
  // ============ Gradients ============
  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
  
  static LinearGradient get surfaceGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surface, surface.withValues(alpha: 0.95)],
  );
  
  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceContainerLowest, surfaceContainerLow],
  );
  
  // ============ Shadows ============
  static List<BoxShadow> get softShadow => [
    BoxShadow(offset: const Offset(0, 2), blurRadius: 8, color: Colors.black.withValues(alpha: 0.04)),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(offset: const Offset(0, 4), blurRadius: 16, color: Colors.black.withValues(alpha: 0.06)),
  ];
  
  static List<BoxShadow> get largeShadow => [
    BoxShadow(offset: const Offset(0, 8), blurRadius: 24, color: Colors.black.withValues(alpha: 0.08)),
  ];
  
  // ============ Neumorphism Shadows ============
  static List<BoxShadow> get neumorphicShadow => [
    BoxShadow(offset: const Offset(8, 8), blurRadius: 16, color: const Color(0xFFE2E2E2)),
    BoxShadow(offset: const Offset(-8, -8), blurRadius: 16, color: Colors.white),
  ];
  
  static List<BoxShadow> get neumorphicPressed => [
    BoxShadow(offset: const Offset(4, 4), blurRadius: 8, color: const Color(0xFFE2E2E2)),
    BoxShadow(offset: const Offset(-4, -4), blurRadius: 8, color: Colors.white),
  ];
  
  // ============ Typography (using Cairo font - supports Arabic) ============
  static TextStyle get displayLg => GoogleFonts.cairo(
    fontSize: 48, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.02, color: onSurface,
  );
  
  static TextStyle get headlineXl => GoogleFonts.cairo(
    fontSize: 32, fontWeight: FontWeight.w700, height: 1.25, letterSpacing: -0.01, color: onSurface,
  );
  
  static TextStyle get headlineLg => GoogleFonts.cairo(
    fontSize: 24, fontWeight: FontWeight.w600, height: 1.33, color: onSurface,
  );
  
  static TextStyle get headlineMd => GoogleFonts.cairo(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4, color: onSurface,
  );
  
  static TextStyle get bodyLg => GoogleFonts.cairo(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: onSurface,
  );
  
  static TextStyle get bodyMd => GoogleFonts.cairo(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, color: onSurfaceVariant,
  );
  
  static TextStyle get labelLg => GoogleFonts.cairo(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, color: onSurfaceVariant,
  );
  
  static TextStyle get labelMd => GoogleFonts.cairo(
    fontSize: 12, fontWeight: FontWeight.w600, height: 1.33, letterSpacing: 0.02, color: onSurfaceVariant,
  );
  
  static TextStyle get labelSm => GoogleFonts.cairo(
    fontSize: 11, fontWeight: FontWeight.w500, height: 1.27, color: outline,
  );
  
  // ============ Theme Data ============
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.cairo().fontFamily,
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
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.95),
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headlineMd,
        iconTheme: const IconThemeData(color: primary),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surfaceContainerLowest,
        shadowColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: bodyMd.copyWith(color: outline),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 48),
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: labelLg,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary, textStyle: bodyMd),
      ),
      iconTheme: const IconThemeData(color: primary, size: 22),
      dividerTheme: const DividerThemeData(color: outlineVariant, thickness: 0.5),
    );
  }
  
  static ThemeData get darkTheme => lightTheme;
}