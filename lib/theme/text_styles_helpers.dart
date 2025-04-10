import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Helper functions for font styles
TextStyle getOrbitron(
    {double fontSize = 34,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 2.0,
    List<Shadow>? shadows}) {
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

TextStyle getQuantico(
    {double fontSize = 22,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 1.2}) {
  return GoogleFonts.quantico(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: AppColors.textColor.withOpacity(0.85),
    letterSpacing: letterSpacing,
  );
}

TextStyle getExo2(
    {double fontSize = 26,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 1.5,
    List<Shadow>? shadows}) {
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

TextStyle getRajdhani(
    {double fontSize = 26,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 1.5,
    List<Shadow>? shadows}) {
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

TextStyle getRoboto(
    {double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white}) {
  return GoogleFonts.roboto(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

//Playfair Display style
TextStyle getPlayfairDisplay(
    {double fontSize = 26,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.2,
    List<Shadow>? shadows}) {
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
