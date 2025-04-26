import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cameraSelectionDropdown_provider.dart';
import 'providers/image_list_provider.dart';
import 'providers/navigationbar_provider.dart';
import 'screens/AGRIVISION_PAGE.dart';
import 'screens/disease_detection_page.dart';
import 'screens/growth_monitoring_page.dart';
import 'providers/yolo_provider.dart';
import 'screens/health_analyse_page.dart';
import 'screens/home_page.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => YOLOProvider(websocketUrl: 'ws://localhost:8000')),
        ChangeNotifierProvider(create: (_) => NavigationBarProvider()),
        ChangeNotifierProvider(
            create: (_) => CameraSelectionDropdownProvider()),
        ChangeNotifierProvider(create: (_) => ImageListProvider()),
      ],
      child: MaterialApp(
        title: 'Agrihub Dashboard',
        theme: ThemeData(
          primaryColor: AppColors.topBar,
          scaffoldBackgroundColor: AppColors.monitoring_pages_background,
        ),
        initialRoute: '/home', // Define the initial route
        routes: {
          '/home': (context) => HomePage(), // Home page route
          '/growth': (context) => GrowthMonitoringPage(), // Growth page route
          '/health': (context) => HealthAnalysisPage(), // Health page route
          '/disease': (context) => DiseaseDetectionPage(), // Disease page route
          '/agrivision': (context) => AgrivisionPage(), // Agrivision page route
        },
      ),
    );
  }
}
