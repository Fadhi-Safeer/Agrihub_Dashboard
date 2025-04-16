import 'package:flutter/material.dart';
import '../utils/text_util.dart'; // Import the helper functions
import 'app_colors.dart';

class TextStyles {
  // 🌟 Assigned Styles using the Helper Functions
  static TextStyle mainHeading = TextUtils.getOrbitron();

  static TextStyle rightPanelHeadingText = TextUtils.getQuantico();

  static TextStyle modern = TextUtils.getExo2();

  static TextStyle futuristic = TextUtils.getExo2();

  static TextStyle retro = TextUtils.getRajdhani();

  //Growth, Health, and Disease Pages
  static TextStyle graphSectionTitle = TextUtils.getOrbitron(
          fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.0)
      .copyWith(
    color: AppColors.cardNumberColor,
  );

  static TextStyle elevatedCardTitle = TextUtils.getMontserrat(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.sidebarBackground);

  static TextStyle elevatedCardDescription = TextUtils.getWorkSans(
      fontSize: 17.5,
      fontWeight: FontWeight.w500,
      color: AppColors.elevatedCardDescription);

  static TextStyle sidebarMenuItem =
      TextUtils.getRajdhani(fontSize: 23, fontWeight: FontWeight.w500);

  static TextStyle sidebarMenuItemSelected =
      TextUtils.getRajdhani(fontSize: 23, fontWeight: FontWeight.bold);
}
