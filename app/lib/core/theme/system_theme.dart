import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemTheme {
  static const Color background = Color(0xFF070B14);
  static const Color surface = Color(0xFF0F172A);
  static const Color surfaceElevated = Color(0xFF1E293B);
  
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF38BDF8);
  static const Color divinePurple = Color(0xFFA855F7);
  static const Color spartanGold = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color hunterGreen = Color(0xFF10B981);
  
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static BoxDecoration holographicBoxDecoration({
    Color borderColor = neonCyan,
    double opacity = 0.85,
    double borderRadius = 12.0,
  }) {
    return BoxDecoration(
      color: surface.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor.withOpacity(0.5),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withOpacity(0.2),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static ThemeData get themeData {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: neonCyan,
      cardColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: electricBlue,
        surface: surface,
        error: dangerRed,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          color: textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 32,
          letterSpacing: 2.0,
        ),
        headlineMedium: GoogleFonts.orbitron(
          color: neonCyan,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.orbitron(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
