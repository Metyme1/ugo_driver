import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary — Deep Blue (matches parent app exactly)
  static const Color primary = Color(0xFF1565C0);      // Deep Blue 800
  static const Color primaryLight = Color(0xFF1E88E5); // Blue 600
  static const Color primaryDark = Color(0xFF0D47A1);  // Blue 900

  // Accent — Cyan (matches parent app exactly)
  static const Color accent = Color(0xFF00ACC1);       // Cyan 600
  static const Color accentLight = Color(0xFF00BCD4);  // Cyan 500
  static const Color accentDark = Color(0xFF00838F);   // Cyan 700

  // Gradient (matches parent app exactly)
  static const Color gradientStart = Color(0xFF1E88E5);
  static const Color gradientEnd = Color(0xFF0D47A1);

  // Secondary — Teal (matches parent app exactly)
  static const Color secondary = Color(0xFF26A69A);    // Teal 400
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00796B);

  // Neutrals (matches parent app exactly)
  static const Color background = Color(0xFFF8FAFB);
  static const Color surface = Color(0xFFEEF2FF);      // Faint blue tint
  static const Color card = Color(0xFFFFFFFF);

  // Text (matches parent app exactly)
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textHint = Color(0xFF94A3B8);     // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status (matches parent app exactly)
  static const Color success = Color(0xFF16A34A);      // Green 700
  static const Color warning = Color(0xFFD97706);      // Amber 600
  static const Color error = Color(0xFFDC2626);        // Red 600
  static const Color info = Color(0xFF0284C7);         // Sky 600

  // Others (matches parent app exactly)
  static const Color border = Color(0xFFE2E8F0);       // Slate 200
  static const Color divider = Color(0xFFF1F5F9);      // Slate 100
  static const Color disabled = Color(0xFFCBD5E1);     // Slate 300
  static const Color inputFill = Color(0xFFF0F4FF);    // Very light blue

  // Gradients (matches parent app exactly)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF1565C0),
      Color(0xFF0D47A1),
    ],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E88E5),
      Color(0xFF0D47A1),
    ],
  );

  // Cyan gradient for scan button & accent elements
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00ACC1), Color(0xFF00838F)],
  );

  // Dark navy for the bottom nav bar
  static const LinearGradient darkNavGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B3E), Color(0xFF0A2060)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),

      textTheme: base.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 34, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, letterSpacing: -0.3,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24, fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 19, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w400,
          color: AppColors.textPrimary, letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: Colors.white, letterSpacing: 0.3,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary, letterSpacing: -0.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2)),
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: AppColors.textHint),
        labelStyle: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider, thickness: 1),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
      ),
    );
  }
}
