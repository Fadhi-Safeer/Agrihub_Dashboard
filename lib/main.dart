// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/viewers_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrihub Dashboard',
      theme: ThemeData(
        primaryColor: AppColors.purpleDark,
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      home: ViewersPage(),
    );
  }
}
