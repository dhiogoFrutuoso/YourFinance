import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cores Principais
  static const Color background = Color(0xFF000000); // Preto absoluto
  static const Color cardColor = Color(0xFF121212); // Cinza muito escuro
  static const Color elevatedColor = Color(0xFF1A1A1A); // Cinza escuro elevado
  static const Color primary = Color(0xFF9D00FF); // Roxo LED
  static const Color primaryLight = Color(0xFF8A2BE2); // Roxo variante
  
  // Cores Semânticas
  static const Color success = Color(0xFF10B981); // Verde
  static const Color error = Color(0xFFEF4444); // Vermelho
  static const Color warning = Color(0xFFF59E0B); // Laranja

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: cardColor,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.normal, color: Colors.white70),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.normal, color: Colors.white70),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevatedColor,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white54,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
