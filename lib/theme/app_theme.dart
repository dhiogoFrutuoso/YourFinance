import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Design System Tokens (Premium Dark Purple) ─────────────────
  static const Color colorCanvas = Color(0xFF050505);
  static const Color colorPaper = Color(0xFF111113);
  static const Color colorHairline = Color(0xFF27272A);
  static const Color colorInk = Color(0xFFFAFAFA);
  static const Color colorInkSoft = Color(0xFFA1A1AA);
  static const Color colorPrimary = Color(0xFF8B5CF6);
  static const Color colorPrimaryDark = Color(0xFF7C3AED);
  static const Color colorDestructive = Color(0xFFEF4444);

  // ─── Geometry ───────────────────────────────────────────────────
  static const double interactiveRadius = 18.0;
  static const double containerRadius = 24.0;

  // ─── Shadows (Premium Glow) ─────────────────────────────────────
  static List<BoxShadow> get premiumGlow => [
        BoxShadow(
          color: colorPrimary.withOpacity(0.15),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  // ─── Backward Compatibility Getters ───────────────────────────────
  static const Color background = colorCanvas;
  static const Color surface = colorPaper;
  static const Color primary = colorPrimary;
  static const Color textPrimary = colorInk;
  static const Color textSecondary = colorInkSoft;
  static const Color textTertiary = Color(0xB3A1A1AA);
  static const Color textDisabled = Color(0x80A1A1AA);
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = colorDestructive;
  static const Color warning = Color(0xFFF59E0B); // Amber
  
  static const double cardRadius = containerRadius;
  static const double modalRadius = containerRadius;
  
  static const double glassOpacity = 1.0;
  static const double glassBorderOpacity = 1.0;
  static const double glassBlurSigma = 0.0;

  static List<BoxShadow> glowShadow({double blurRadius = 16, double opacity = 0.35, double spreadRadius = 0}) => premiumGlow;
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [colorPrimaryDark, colorPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Theme Data ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorCanvas,
      primaryColor: colorPrimary,
      colorScheme: const ColorScheme.dark(
        primary: colorPrimary,
        secondary: colorPrimaryDark,
        surface: colorPaper,
        error: colorDestructive,
        onPrimary: colorInk,
        onSurface: colorInk,
        onError: colorInk,
      ),

      // ─── Typography (The "Clinical Blueprint" soul) ───
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 48, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -2.4,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -1.8,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 30, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -1.5,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -1.2,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -1.0,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -0.8,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: 0,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: colorInkSoft, letterSpacing: 0,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, color: colorInkSoft, letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, color: colorInkSoft, letterSpacing: 0,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: colorInk, letterSpacing: 0.6,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: colorInkSoft, letterSpacing: 0.6,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w500, color: colorInkSoft, letterSpacing: 0.6,
        ),
      ),

      // ─── AppBar ───
      appBarTheme: AppBarTheme(
        backgroundColor: colorCanvas,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: colorInk, letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: colorInk),
        surfaceTintColor: Colors.transparent,
      ),

      // ─── Cards ───
      cardTheme: CardThemeData(
        color: colorPaper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerRadius),
          side: const BorderSide(color: colorHairline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Elevated Buttons ───
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: colorInk,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), // Approx 44px height
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(interactiveRadius)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0),
          minimumSize: const Size(0, 44),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorPrimaryDark.withOpacity(0.5);
            }
            return null;
          }),
        ),
      ),

      // ─── Text Buttons (Ghost style defaults) ───
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorInkSoft,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 16, letterSpacing: 0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(interactiveRadius),
            side: const BorderSide(color: colorHairline, width: 1),
          ),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused) || states.contains(WidgetState.selected)) {
              return colorPrimary;
            }
            return colorInkSoft;
          }),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) || states.contains(WidgetState.focused) || states.contains(WidgetState.selected)) {
              return const BorderSide(color: colorPrimary, width: 1);
            }
            return const BorderSide(color: colorHairline, width: 1);
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorPrimary.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),

      // ─── Input Decoration ───
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorPaper,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: colorInkSoft, fontSize: 14, fontWeight: FontWeight.w400),
        labelStyle: GoogleFonts.inter(color: colorInkSoft, fontSize: 14, fontWeight: FontWeight.w400),
        floatingLabelStyle: GoogleFonts.inter(color: colorPrimary, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          borderSide: BorderSide.none, // Transparent border on rest
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          borderSide: const BorderSide(color: colorPrimary, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          borderSide: const BorderSide(color: colorDestructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          borderSide: const BorderSide(color: colorDestructive, width: 1),
        ),
      ),

      // ─── Dialog ───
      dialogTheme: DialogThemeData(
        backgroundColor: colorPaper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(containerRadius),
          side: const BorderSide(color: colorHairline, width: 1),
        ),
        elevation: 0,
      ),

      // ─── Bottom Sheet ───
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorPaper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(containerRadius)),
        ),
        elevation: 0,
        modalBackgroundColor: colorPaper,
        modalElevation: 0,
      ),

      // ─── Divider ───
      dividerTheme: const DividerThemeData(
        color: colorHairline,
        thickness: 1,
        space: 1,
      ),

      // ─── Bottom Nav ───
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: colorCanvas,
        selectedItemColor: colorPrimary,
        unselectedItemColor: colorInkSoft,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ─── Floating Action Button ───
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorPrimary,
        foregroundColor: colorInk,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(interactiveRadius)),
      ),

      // ─── Chip ───
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: colorPrimary.withOpacity(0.15),
        disabledColor: colorPaper,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: colorInk, letterSpacing: 0.6),
        side: const BorderSide(color: colorHairline, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(interactiveRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      
      // ─── SnackBar ───
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorPaper,
        contentTextStyle: GoogleFonts.inter(color: colorInk, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(interactiveRadius),
          side: const BorderSide(color: colorHairline, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ─── Progress Indicator ───
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: colorPrimary,
        linearTrackColor: colorHairline,
      ),
    );
  }
}
