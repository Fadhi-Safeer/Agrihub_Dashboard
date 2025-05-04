import 'dart:math';

import 'package:camera/camera.dart';
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
              child: LayoutBuilder(builder: (context, constraints) {
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
                            '75%',
                            Colors.green,
                            [
                              Color.fromRGBO(169, 45, 101, 1.0), // Fully opaque
                              Color.fromRGBO(229, 125, 126, 1.0),
                            ],
                          ),
                          const SizedBox(width: 20),
                          _buildTopBarCard(
                            'IMAGES PROCESSED',
                            '3,924',
                            AppColors
                                .sidebarGradientStart, // Assuming this is defined correctly
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
                              Color.fromRGBO(
                                  231, 105, 127, 1.0), // Fully opaque
                              Color.fromRGBO(
                                  231, 186, 127, 1.0), // Fully opaque
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
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
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
                                                  'Smart Insights',
                                                  style: TextStyles
                                                      .elevatedCardTitle
                                                      .copyWith(
                                                    color: AppColors
                                                        .sidebarGradientStart,
                                                  ),
                                                ),
                                                Text(
                                                  'Tap for AI-generated recommendations',
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
                                  child: ElevatedCard(
                                    title: 'CROP METRICS TREND',
                                    description: 'Last 30 days comparison',
                                    backgroundColor: Colors.white,
                                    height: 320,
                                    showTopBar: true,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: MultiGradientLineChart(
                                        showArea: true,
                                        showMarkers: true,
                                        dataSets: [
                                          TimeSeriesDataSet(
                                            name: 'Temperature (°C)',
                                            color: Colors.red,
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red.withOpacity(0.3),
                                                Colors.red.withOpacity(0.1)
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            data: List.generate(30, (index) {
                                              final date = DateTime.now()
                                                  .subtract(Duration(
                                                      days: 29 - index));
                                              // Simulated temperature data (20-35°C range)
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
                                                Colors.blue.withOpacity(0.1)
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            data: List.generate(30, (index) {
                                              final date = DateTime.now()
                                                  .subtract(Duration(
                                                      days: 29 - index));
                                              // Simulated humidity data (40-80% range)
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
                                                Colors.green.withOpacity(0.1)
                                              ],
                                              stops: [0.0, 1.0],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            data: List.generate(30, (index) {
                                              final date = DateTime.now()
                                                  .subtract(Duration(
                                                      days: 29 - index));
                                              // Simulated soil moisture data (30-70% range)
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

                          // Right: AgriVision fills full column height
                          Expanded(
                            flex: 1,
                            child: ElevatedCard(
                              title: 'AGRIVISION',
                              description: 'Advanced tools',
                              backgroundColor: Colors.white,
                              height: double.infinity,
                              showTopBar: true,
                              child: InkWell(
                                onTap: () {/* Navigation */},
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.agriculture,
                                        size: 60,
                                        color: AppColors.sidebarGradientStart,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Explore AgriVision',
                                        style: TextStyles.elevatedCardTitle
                                            .copyWith(
                                          color: AppColors.sidebarGradientStart,
                                        ),
                                      ),
                                    ],
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
              }),
            ),
          ),
        ],
      ),
    );
  }
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
      title: Text('Field Summary', style: TextStyles.elevatedCardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint('Overall crop health is good (75%)'),
          const SizedBox(height: 8),
          _buildBulletPoint('3 areas need attention (see alerts)'),
          const SizedBox(height: 8),
          _buildBulletPoint('Optimal growth rate detected'),
          const SizedBox(height: 8),
          _buildBulletPoint('Next irrigation recommended in 2 days'),
          const SizedBox(height: 16),
          Text(
            'Recommendations:',
            style: TextStyles.elevatedCardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint('Apply nitrogen fertilizer in northern section'),
          const SizedBox(height: 8),
          _buildBulletPoint('Schedule pest control for next week'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Dismiss',
              style: TextStyle(color: AppColors.sidebarGradientStart)),
        ),
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
