// lib/resource/text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class TextStyles {
  // 🌟 Main Heading (Futuristic Glow Effect - Orbitron)
  static TextStyle mainHeading = GoogleFonts.orbitron(
    fontSize: 34, // Slightly larger for impact
    fontWeight: FontWeight.bold,
    color: AppColors.textColor, // Soft White for readability
    letterSpacing: 2.0, // Increased spacing for a sleek look
    shadows: [
      Shadow(
        color: AppColors.neonCyan.withOpacity(0.7), // Cyan Glow
        blurRadius: 15,
      ),
      Shadow(
        color: AppColors.neonGreen.withOpacity(0.5), // Secondary Green Glow
        blurRadius: 10,
      ),
    ],
  );

  // 🔹 Right Panel Heading (Sleek & Minimalist - Quantico)
  static TextStyle rightPanelHeadingText = GoogleFonts.quantico(
    fontSize: 22, // Slightly bigger for section headers
    fontWeight: FontWeight.w600, // Stronger weight for importance
    color: AppColors.textColor
        .withOpacity(0.85), // Softer white for better contrast
    letterSpacing: 1.2, // Balanced spacing
  );
}
