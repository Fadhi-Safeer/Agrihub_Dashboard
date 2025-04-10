import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

// TextStylesHelper class for font style helpers
class TextUtils {
  // Helper function for Orbitron font style
  static TextStyle getOrbitron({
    double fontSize = 34,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 2.0,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.textColor,
      letterSpacing: letterSpacing,
      shadows: shadows ??
          [
            Shadow(
              color: AppColors.neonCyan.withOpacity(0.7),
              blurRadius: 15,
            ),
            Shadow(
              color: AppColors.neonGreen.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
    );
  }

  // Helper function for Quantico font style
  static TextStyle getQuantico({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 1.2,
  }) {
    return GoogleFonts.quantico(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.textColor.withOpacity(0.85),
      letterSpacing: letterSpacing,
    );
  }

  // Helper function for Exo2 font style
  static TextStyle getExo2({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 1.5,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.exo2(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.neonCyan,
      letterSpacing: letterSpacing,
      shadows: shadows ??
          [
            Shadow(
              color: AppColors.neonCyan.withOpacity(0.8),
              blurRadius: 20,
            ),
            Shadow(
              color: AppColors.neonGreen.withOpacity(0.6),
              blurRadius: 15,
            ),
          ],
    );
  }

  // Helper function for Rajdhani font style
  static TextStyle getRajdhani({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 1.5,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.textColor,
      letterSpacing: letterSpacing,
      shadows: shadows ??
          [
            Shadow(
              color: AppColors.neonCyan.withOpacity(0.6),
              blurRadius: 12,
            ),
          ],
    );
  }

  // Helper function for Roboto font style
  static TextStyle getRoboto({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Helper function for Playfair Display font style
  static TextStyle getPlayfairDisplay({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.2,
    List<Shadow>? shadows,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.textColor,
      letterSpacing: letterSpacing,
      shadows: shadows ??
          [
            Shadow(
              color: AppColors.neonCyan.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
    );
  }
}
