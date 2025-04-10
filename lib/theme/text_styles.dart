import 'package:flutter/material.dart';
import 'text_styles_helpers.dart'; // Import the helper functions
import 'app_colors.dart';

class TextStyles {
  // 🌟 Assigned Styles using the Helper Functions
  static TextStyle mainHeading = getOrbitron();

  static TextStyle rightPanelHeadingText = getQuantico();

  static TextStyle modern = getExo2();

  static TextStyle futuristic = getExo2();

  static TextStyle retro = getRajdhani();

  //Growth, Health, and Disease Pages
  static TextStyle graphSectionTitle =
      getOrbitron(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.0)
          .copyWith(
    color: AppColors.cardNumberColor,
  );

  static TextStyle growthStageCardTitle = getRoboto(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.sidebarBackground);

  static TextStyle sidebarMenuItem = getRoboto(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textColor.withOpacity(0.7));

  static TextStyle sidebarMenuItemSelected = getRoboto(
      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor);
}
