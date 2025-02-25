// lib/resource/text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextStyles {
  // Main Heading (Futuristic Orbitron)
  static TextStyle mainHeading = GoogleFonts.orbitron(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.5,
    shadows: [
      Shadow(
        color: Colors.blueAccent.withOpacity(0.8),
        blurRadius: 10,
      ),
    ],
  );

  // Camera Text (Bright neon Rajdhani)
  static TextStyle cameraText = GoogleFonts.rajdhani(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.cyanAccent,
    shadows: [
      Shadow(
        color: Colors.cyanAccent.withOpacity(0.9),
        blurRadius: 15,
      ),
    ],
  );

  // Right Panel Text (Minimalist Quantico)
  static TextStyle rightPanelText = GoogleFonts.quantico(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white70,
  );

  // Graph Text (Subtle & Clean)
  static TextStyle graphText = GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Colors.white60,
  );
}
