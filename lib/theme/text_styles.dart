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

  //Growth,Health And Disease Pages
  // 🔹 Graph Section Title
  static TextStyle graphSectionTitle = GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.cardNumberColor, // Purple[800]
  );

  // 🔹 GrowthStageCard Title
  static TextStyle growthStageCardTitle = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.sidebarBackground, // Purple[900]
  );

  // 🔹 Sidebar Menu Item
  static TextStyle sidebarMenuItem = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textColor.withOpacity(0.7), // White70
  );

  static TextStyle sidebarMenuItemSelected = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor, // White
  );
}
