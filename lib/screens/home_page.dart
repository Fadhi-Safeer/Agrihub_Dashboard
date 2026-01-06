import 'package:agrihub_dashboard/utils/available_cameras.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../widgets/graphs/time_series_chart.dart';
import '../widgets/monitoring_pages/elevated_card.dart';
import '../widgets/navigation_sidebar.dart';
import '../globals.dart';

// ✅ Firestore logic separated into a service file
import '../../services/firestore_history_service.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // ✅ Single service instance (keeps HomePage clean)
  final FirestoreHistoryService _historyService = FirestoreHistoryService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final cameras = getAvailableCameras();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Agricultural Growth & Research with AI Vision',
                            style: TextStyles.mainHeading.copyWith(
                              color: AppColors.sidebarGradientStart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Top Metrics Row
                      SizedBox(
                        height: availableHeight * 0.3,
                        child: Row(
                          children: [
                            _buildTopBarCard(
                              'AI MODELS',
                              '5',
                              Colors.green,
                              const [
                                Color.fromRGBO(169, 45, 101, 1.0),
                                Color.fromRGBO(229, 125, 126, 1.0),
                              ],
                            ),
                            const SizedBox(width: 20),
                            _buildTopBarCard(
                              'SITES ACTIVE',
                              '${cameras.length} Camera${cameras.length == 1 ? '' : 's'}',
                              AppColors.sidebarGradientStart,
                              const [
                                Color.fromRGBO(231, 105, 127, 1.0),
                                Color.fromRGBO(231, 105, 127, 1.0),
                              ],
                            ),
                            const SizedBox(width: 20),
                            _buildTopBarCard(
                              'IOT SENSORS',
                              '3 Sensor Types',
                              Colors.orange,
                              const [
                                Color.fromRGBO(231, 105, 127, 1.0),
                                Color.fromRGBO(231, 186, 127, 1.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Smart Insights + AgriVision Row
                      Expanded(
                        child: Row(
                          children: [
                            // Left: Smart Insights + Crop Health Trend
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  // Smart Insights
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () => _showSummaryDialog(context),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.insights,
                                                color: AppColors
                                                    .sidebarGradientStart),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'About',
                                                    style: TextStyles
                                                        .elevatedCardTitle
                                                        .copyWith(
                                                      color: AppColors
                                                          .sidebarGradientStart,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Tap for more info about our project',
                                                    style: TextStyles
                                                        .elevatedCardDescription,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(Icons.chevron_right,
                                                color: AppColors
                                                    .sidebarGradientStart),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Crop Health Trend (FROM FIRESTORE SERVICE)
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      height: 320,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: StreamBuilder<
                                            QuerySnapshot<
                                                Map<String, dynamic>>>(
                                          stream: _historyService.historyStream(
                                            appId: appId,
                                            days: 30,
                                            limit: 5000,
                                          ),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Center(
                                                child: Text(
                                                  'Firestore error:\n${snapshot.error}',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: Colors.red),
                                                ),
                                              );
                                            }

                                            if (!snapshot.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            final docs = snapshot.data!.docs;
                                            if (docs.isEmpty) {
                                              return const Center(
                                                child: Text(
                                                  'No historical data found for the last 30 days.',
                                                ),
                                              );
                                            }

                                            final tempPoints =
                                                <TimeSeriesData>[];
                                            final humidityPoints =
                                                <TimeSeriesData>[];
                                            final soilPoints =
                                                <TimeSeriesData>[];

                                            for (final d in docs) {
                                              final record = d.data();

                                              final ts = record['timestamp'];
                                              if (ts is! Timestamp) continue;
                                              final time = ts.toDate();

                                              final temp = _historyService
                                                  .getReadingValue(
                                                      record, const [
                                                'Temperature',
                                                'environment_temperature',
                                                'temp',
                                                'temperature',
                                              ]);

                                              final hum = _historyService
                                                  .getReadingValue(
                                                      record, const [
                                                'Humidity',
                                                'environment_humidity',
                                                'hum',
                                                'humidity',
                                              ]);

                                              final soil = _historyService
                                                  .getReadingValue(
                                                      record, const [
                                                'Soil Moisture',
                                                'Soil_Moisture',
                                                'soil_moisture',
                                                'soilMoisture',
                                                'moisture',
                                              ]);

                                              if (temp != null) {
                                                tempPoints.add(
                                                    TimeSeriesData(time, temp));
                                              }
                                              if (hum != null) {
                                                humidityPoints.add(
                                                    TimeSeriesData(time, hum));
                                              }
                                              if (soil != null) {
                                                soilPoints.add(
                                                    TimeSeriesData(time, soil));
                                              }
                                            }

                                            if (tempPoints.isEmpty &&
                                                humidityPoints.isEmpty &&
                                                soilPoints.isEmpty) {
                                              return const Center(
                                                child: Text(
                                                  'No valid readings found.\nCheck your Firestore keys inside "readings".',
                                                  textAlign: TextAlign.center,
                                                ),
                                              );
                                            }

                                            final dataSets =
                                                <TimeSeriesDataSet>[];

                                            if (tempPoints.isNotEmpty) {
                                              dataSets.add(
                                                TimeSeriesDataSet(
                                                  name: 'Temperature (°C)',
                                                  color: Colors.red,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.red
                                                          .withOpacity(0.3),
                                                      Colors.red
                                                          .withOpacity(0.1),
                                                    ],
                                                    stops: const [0.0, 1.0],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  data: tempPoints,
                                                ),
                                              );
                                            }

                                            if (humidityPoints.isNotEmpty) {
                                              dataSets.add(
                                                TimeSeriesDataSet(
                                                  name: 'Humidity (%)',
                                                  color: Colors.blue,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.blue
                                                          .withOpacity(0.3),
                                                      Colors.blue
                                                          .withOpacity(0.1),
                                                    ],
                                                    stops: const [0.0, 1.0],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  data: humidityPoints,
                                                ),
                                              );
                                            }

                                            if (soilPoints.isNotEmpty) {
                                              dataSets.add(
                                                TimeSeriesDataSet(
                                                  name: 'Soil Moisture',
                                                  color: Colors.green,
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.green
                                                          .withOpacity(0.3),
                                                      Colors.green
                                                          .withOpacity(0.1),
                                                    ],
                                                    stops: const [0.0, 1.0],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                  data: soilPoints,
                                                ),
                                              );
                                            }

                                            return TimeSeriesChart(
                                              showArea: true,
                                              showMarkers: false,
                                              dataSets: dataSets,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),

                            // Right: AgriVision Card
                            Expanded(
                              flex: 1,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromRGBO(241, 75, 121, 0.08),
                                        Color.fromRGBO(241, 75, 121, 0.04),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color.fromRGBO(
                                          241, 75, 121, 0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color:
                                            Color.fromRGBO(241, 75, 121, 0.1),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => Navigator.pushNamed(
                                          context, '/agrivision'),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: const Color.fromRGBO(
                                                    241, 75, 121, 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      241, 75, 121, 0.3),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 100),
                                                child: Image.asset(
                                                  'assets/camera.png',
                                                  fit: BoxFit.contain,
                                                  color:
                                                      const Color(0xFF8E3A59),
                                                  colorBlendMode:
                                                      BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'Explore AgriVision',
                                              style: TextStyles
                                                  .elevatedCardTitle
                                                  .copyWith(
                                                color: const Color.fromRGBO(
                                                    241, 75, 121, 1.0),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'AI-powered crop insights',
                                              style: TextStyles
                                                  .elevatedCardDescription
                                                  .copyWith(
                                                color: const Color.fromRGBO(
                                                    241, 75, 121, 0.7),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              width: 100,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        241, 75, 121, 0.6),
                                                    Color.fromRGBO(
                                                        241, 75, 121, 0.3),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTopBarCard(
    String title,
    String value,
    Color color, [
    List<Color> topBarGradientColors = const [
      Color(0xFFFF5E9C),
      Color(0xFFFFB157),
    ],
  ]) {
    return Expanded(
      child: ElevatedCard(
        title: title,
        description: 'Current status',
        backgroundColor: Colors.white,
        height: double.infinity,
        showTopBar: true,
        topBarGradientColors: topBarGradientColors,
        child: Center(
          child: Text(
            value,
            style: TextStyles.elevatedCardTitle.copyWith(
              fontSize: 32,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _showSummaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About AgriVision AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.sidebarGradientStart,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgriVision, short for "Agricultural Growth & Research with AI Vision", is an innovative AI-driven monitoring system developed under APCORE (Asia Pacific Center of Robotics Engineering).',
              style: TextStyles.aboutCardDescription,
            ),
            const SizedBox(height: 12),
            Text(
              'This project empowers researchers and farmers with real-time insights into crop health, growth patterns, and disease detection. Using advanced computer vision and deep learning models (like YOLO), it enables seamless monitoring and smart decision-making for both hydroponic and traditional farms.',
              style: TextStyles.aboutCardDescription,
            ),
            const SizedBox(height: 12),
            Text(
              'AgriVision is designed to be accessible, scalable, and cloud-integrated—offering a futuristic yet practical solution to modern agricultural challenges.',
              style: TextStyles.aboutCardDescription,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColors.sidebarGradientStart),
            ),
          ),
        ],
      ),
    );
  }
}
