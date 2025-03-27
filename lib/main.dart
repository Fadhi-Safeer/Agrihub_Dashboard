// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/viewers_page.dart';
import 'providers/yolo_provider.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => YOLOProvider()),
      ],
      child: MaterialApp(
        title: 'Agrihub Dashboard',
        theme: ThemeData(
          primaryColor: AppColors.topBar,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: ViewersPage(),
      ),
    );
  }
}
