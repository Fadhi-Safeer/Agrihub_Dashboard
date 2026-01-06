import 'package:agrihub_dashboard/providers/sensorHistoryProvider.dart';
import 'package:agrihub_dashboard/screens/auth_gate.dart';
import 'package:agrihub_dashboard/screens/prediction_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cameraSelectionDropdown_provider.dart';
import 'providers/health_status_provider.dart';
import 'providers/image_list_provider.dart';
import 'providers/navigationbar_provider.dart';
import 'screens/AGRIVISION_PAGE.dart';
import 'screens/disease_detection_page.dart';
import 'screens/growth_monitoring_page.dart';
import 'providers/yolo_provider.dart';
import 'screens/health_analyse_page.dart';
import 'screens/home_page.dart';
import 'screens/settings_page.dart';
import 'theme/app_colors.dart';
import 'widgets/chatbot/floating_stack_chatbot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => HealthStatusProvider()),
        ChangeNotifierProvider(
          create: (_) => SensorHistoryProvider(appId: appId),
        ),
      ],
      child: MaterialApp(
        title: 'Agrihub Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.topBar,
          scaffoldBackgroundColor: AppColors.monitoring_pages_background,
        ),
        initialRoute: '/login',
        routes: {
          '/home': (context) => HomePage(),
          '/growth': (context) => GrowthMonitoringPage(),
          '/health': (context) => HealthAnalysisPage(),
          '/disease': (context) => DiseaseDetectionPage(),
          '/agrivision': (context) => AgrivisionPage(),
          '/settings': (context) => SettingsPage(),
          '/prediction': (context) => const PredictionPage(),
          '/login': (context) => AuthGate(),
        },
        builder: (context, child) => FloatingStackChatbot(child: child!),
      ),
    );
  }
}
