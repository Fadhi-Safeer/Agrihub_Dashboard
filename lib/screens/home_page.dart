import 'dart:math';

import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../widgets/graphs/time_series_chart.dart';
import '../widgets/monitoring_pages/elevated_card.dart';
import '../widgets/navigation_sidebar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

                      // Top Metrics Row (increased height)
                      SizedBox(
                        height: availableHeight * 0.3,
                        child: Row(
                          children: [
                            _buildTopBarCard(
                              'FIELD HEALTH',
                              '89%',
                              Colors.green,
                              [
                                Color.fromRGBO(169, 45, 101, 1.0),
                                Color.fromRGBO(229, 125, 126, 1.0),
                              ],
                            ),
                            const SizedBox(width: 20),
                            _buildTopBarCard(
                              'IMAGES PROCESSED',
                              '3,924',
                              AppColors.sidebarGradientStart,
                              [
                                Color.fromRGBO(231, 105, 127, 1.0),
                                Color.fromRGBO(231, 105, 127, 1.0),
                              ],
                            ),
                            const SizedBox(width: 20),
                            _buildTopBarCard(
                              'ALERTS',
                              '12',
                              Colors.orange,
                              [
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
                                  // Smart Insights (Field Summary)
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
                                              offset: Offset(0, 4),
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
                                  // Crop Health Trend
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
                                        child: TimeSeriesChart(
                                          showArea: true,
                                          showMarkers: true,
                                          dataSets: [
                                            TimeSeriesDataSet(
                                              name: 'Temperature (°C)',
                                              color: Colors.red,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.red.withOpacity(0.3),
                                                  Colors.red.withOpacity(0.1),
                                                ],
                                                stops: [0.0, 1.0],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              data: List.generate(30, (index) {
                                                final date = DateTime.now()
                                                    .subtract(Duration(
                                                        days: 29 - index));
                                                final value = 20 +
                                                    (index % 15) +
                                                    Random().nextDouble() * 5;
                                                return TimeSeriesData(
                                                    date, value);
                                              }),
                                            ),
                                            TimeSeriesDataSet(
                                              name: 'Humidity (%)',
                                              color: Colors.blue,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.withOpacity(0.3),
                                                  Colors.blue.withOpacity(0.1),
                                                ],
                                                stops: [0.0, 1.0],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              data: List.generate(30, (index) {
                                                final date = DateTime.now()
                                                    .subtract(Duration(
                                                        days: 29 - index));
                                                final value = 40 +
                                                    (index % 20) +
                                                    Random().nextDouble() * 10;
                                                return TimeSeriesData(
                                                    date, value);
                                              }),
                                            ),
                                            TimeSeriesDataSet(
                                              name: 'Soil Moisture',
                                              color: Colors.green,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green.withOpacity(0.3),
                                                  Colors.green.withOpacity(0.1),
                                                ],
                                                stops: [0.0, 1.0],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                              data: List.generate(30, (index) {
                                                final date = DateTime.now()
                                                    .subtract(Duration(
                                                        days: 29 - index));
                                                final value = 30 +
                                                    (index % 20) +
                                                    Random().nextDouble() * 10;
                                                return TimeSeriesData(
                                                    date, value);
                                              }),
                                            ),
                                          ],
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
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromRGBO(241, 75, 121, 0.08),
                                        Color.fromRGBO(241, 75, 121, 0.04),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Color.fromRGBO(241, 75, 121, 0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color.fromRGBO(241, 75, 121, 0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => Navigator.pushNamed(
                                          context, '/agrivision'),
                                      onHover: (hovering) {},
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
                                                color: Color.fromRGBO(
                                                    241, 75, 121, 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                  color: Color.fromRGBO(
                                                      241, 75, 121, 0.3),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth: 100,
                                                ),
                                                child: Image.asset(
                                                  'assets/camera.png',
                                                  fit: BoxFit.contain,
                                                  color: Color(0xFF8E3A59),
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
                                                color: Color.fromRGBO(
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
                                                color: Color.fromRGBO(
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
                                                gradient: LinearGradient(
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

  Widget _buildTopBarCard(String title, String value, Color color,
      [List<Color> topBarGradientColors = const [
        Color(0xFFFF5E9C), // Pink
        Color(0xFFFFB157), // Orange
      ]]) {
    return Expanded(
      child: ElevatedCard(
        title: title,
        description: 'Current status',
        backgroundColor: Colors.white,
        height: double.infinity, // Takes full available height
        showTopBar: true,
        topBarGradientColors: topBarGradientColors,
        child: Center(
          child: Text(
            value,
            style: TextStyles.elevatedCardTitle.copyWith(
              fontSize: 32, // Larger text for increased height
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

  Widget _buildTabContent(List<String> points) {
    return ListView.separated(
      itemCount: points.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(points[index], style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.sidebarGradientStart,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyles.elevatedCardDescription,
          ),
        ),
      ],
    );
  }
}
