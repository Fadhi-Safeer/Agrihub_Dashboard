import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:agrihub_dashboard/theme/text_styles.dart';
import 'package:flutter/material.dart';
import '../widgets/agrivision_page/camera_grid.dart';
import '../widgets/graphs/area_chart.dart';
import '../widgets/graphs/radar_chart.dart';
import '../widgets/graphs/time_series_chart.dart';
import '../widgets/agrivision_page/right_panel.dart';
import '../utils/size_config.dart';
import '../utils/available_cameras.dart';
import '../widgets/monitoring_pages/graph_section.dart';

class AgrivisionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    List<String> availableCameras = getAvailableCameras();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.topBar,
        centerTitle: true,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set icon (back button) color
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/agrivision_icon.png',
              height: 40,
            ),
            const SizedBox(width: 12),
            Text(
              'Agricultural Growth & Research with AI Vision',
              style: TextStyles.mainHeading.copyWith(color: Colors.white),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the homepage and remove current screen from stack
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(
                          SizeConfig.proportionateScreenWidth(4)),
                      child: CameraGrid(availableCameras: availableCameras),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GraphsSection(
                      title: "Analysis Overview",
                      color: Color.fromRGBO(10, 25, 49, 0.08),
                      height: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4), // less padding
                      graphs: [
                        Expanded(
                          child: TimeSeriesChart(
                            dataSets: [
                              TimeSeriesDataSet(
                                name: 'Nitrogen',
                                data: [
                                  TimeSeriesData(DateTime(2025, 4, 1), 35),
                                  TimeSeriesData(DateTime(2025, 4, 8), 45),
                                  TimeSeriesData(DateTime(2025, 4, 15), 60),
                                  TimeSeriesData(DateTime(2025, 4, 22), 70),
                                  TimeSeriesData(DateTime(2025, 4, 29), 65),
                                ],
                                color: Colors.green,
                                gradient: LinearGradient(
                                  colors: [Colors.green, Colors.greenAccent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              TimeSeriesDataSet(
                                name: 'Phosphorus',
                                data: [
                                  TimeSeriesData(DateTime(2025, 4, 1), 45),
                                  TimeSeriesData(DateTime(2025, 4, 8), 50),
                                  TimeSeriesData(DateTime(2025, 4, 15), 40),
                                  TimeSeriesData(DateTime(2025, 4, 22), 45),
                                  TimeSeriesData(DateTime(2025, 4, 29), 55),
                                ],
                                color: Colors.blue,
                              ),
                              TimeSeriesDataSet(
                                name: 'Potassium',
                                data: [
                                  TimeSeriesData(DateTime(2025, 4, 1), 55),
                                  TimeSeriesData(DateTime(2025, 4, 8), 60),
                                  TimeSeriesData(DateTime(2025, 4, 15), 65),
                                  TimeSeriesData(DateTime(2025, 4, 22), 50),
                                  TimeSeriesData(DateTime(2025, 4, 29), 60),
                                ],
                                color: Colors.orange,
                              ),
                            ],
                            showMarkers: true,
                            showArea: false,
                          ),
                        ),
                        Expanded(
                          child: RadarChart(
                            data: [
                              RadarChartData(label: "Nitrogen", value: 0.75),
                              RadarChartData(label: "Phosphorus", value: 0.65),
                              RadarChartData(label: "Potassium", value: 0.70),
                              RadarChartData(label: "Calcium", value: 0.55),
                              RadarChartData(label: "Magnesium", value: 0.60),
                              RadarChartData(label: "Iron", value: 0.50),
                            ],
                            fillColor: const Color(0xFFFF6B35)
                                .withOpacity(0.3), // Vibrant Pink fill
                            borderColor:
                                const Color(0xFFE91E63), // Vibrant Pink border
                            gridColor: Colors.grey.withOpacity(0.3),
                            labelColor: const Color(
                                0xFF424242), // Dark grey for readability
                            divisions: 5,
                            labelFontSize: 14,
                            borderWidth: 2.0,
                            gridWidth: 1.0,
                            showLabels: true,
                            animate: true,
                            animationDuration: 800,
                          ),
                        ),
                        Expanded(
                          child: StackedAreaChart(
                            xAxisTitle: 'Day',
                            yAxisTitle: 'Growth Progress (%)',
                            seriesData: [
                              ChartData('Day 1', 10, 0, 0, 0),
                              ChartData('Day 3', 25, 5, 0, 0),
                              ChartData('Day 5', 35, 15, 5, 0),
                              ChartData('Day 7', 40, 25, 10, 0),
                              ChartData('Day 10', 20, 45, 20, 0),
                              ChartData('Day 13', 10, 30, 45, 5),
                              ChartData('Day 15', 5, 20, 60, 15),
                              ChartData('Day 18', 0, 10, 50, 35),
                              ChartData('Day 21', 0, 5, 30, 60),
                              ChartData('Day 25', 0, 0, 10, 80),
                              ChartData('Day 28', 0, 0, 0, 100),
                            ],
                            seriesColors: [
                              Color(0xFF29B6F6), // Early Growth - Neon Cyan
                              Color(0xFF00FF00), // Leafy Growth - Neon Green
                              Color(0xFFFF4081), // Head Formation - Neon Pink
                              Color(
                                  0xFF7C4DFF), // Harvest Stage - Vibrant Purple
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: RightPanel(),
            ),
          ],
        ),
      ),
    );
  }
}
