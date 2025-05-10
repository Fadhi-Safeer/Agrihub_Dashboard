import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/graphs/area_chart.dart' as custom_charts;
import '../widgets/graphs/area_chart.dart';
import '../widgets/graphs/correlation_graph.dart';
import '../widgets/monitoring_pages/top_bard.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/bullet_points_card.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';
import '../providers/image_list_provider.dart';
import '../models/ImageCard.dart';
import '../widgets/monitoring_pages/elevated_image_card.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  String selectedCamera = '';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final galleryProvider = Provider.of<ImageListProvider>(context);

    // Create disease analysis ImageCard model
    final ImageCard diseaseAnalysisCard = ImageCard(
      title: 'Disease Analysis',
      color: AppColors.cardBackground,
      slotCount: 1, // Single image
      slotImages: galleryProvider.images.isNotEmpty
          ? [galleryProvider.images.first.url]
          : [],
    );

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                // Top Heading
                TopBar(
                  title: 'Disease Detection',
                  textStyle: TextStyles.mainHeading.copyWith(
                    color: AppColors.sidebarGradientStart,
                  ),
                  bulbSize: 30,
                ),

                // Dropdown with selected value and state change
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(
                    onCameraChanged: (cameraId) {
                      setState(() => selectedCamera = cameraId);
                      // Use camera_view: true as requested
                      galleryProvider.loadImages(cameraId, camera_view: true);
                    },
                  ),
                ),
                const SizedBox(height: 16.0),

                // Analysis Section
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Disease Analysis - Using ElevatedImageCard instead of ElevatedCard
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: galleryProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ElevatedImageCard(stage: diseaseAnalysisCard),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BulletPointsCard(
                              title: 'Key Points',
                              bulletPoints: [
                                'Point 1',
                                'Point 2',
                                'Point 3',
                                'Point 4',
                                'Point 5',
                                'Point 6',
                              ],
                              bulletColors: [
                                Colors.red,
                                Colors.green,
                                Colors.blue,
                                Colors.yellow,
                                Colors.purple,
                                Colors.orange,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Graphs Section
                Expanded(
                  flex:
                      2, // Ensure both charts take up the same amount of space
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disease Progression Analysis',
                            style: TextStyles.elevatedCardTitle,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Row(
                              children: [
                                // Disease rate over time chart (takes 50% of width)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        right: 8), // Equal padding
                                    child: TimeSeriesChart(
                                      dataSets: [
                                        TimeSeriesDataSet(
                                          name: 'Disease Rate',
                                          data: [
                                            TimeSeriesData(
                                                DateTime.now().subtract(
                                                    const Duration(days: 21)),
                                                45),
                                            TimeSeriesData(
                                                DateTime.now().subtract(
                                                    const Duration(days: 14)),
                                                65),
                                            TimeSeriesData(
                                                DateTime.now().subtract(
                                                    const Duration(days: 7)),
                                                35),
                                            TimeSeriesData(DateTime.now(), 20),
                                          ],
                                          color: Colors.red,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.red.withOpacity(0.3),
                                              Colors.red.withOpacity(0.1),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ],
                                      showMarkers: true,
                                      showArea: true,
                                    ),
                                  ),
                                ),
                                // Weather Correlation Graph (remaining 50% of width)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0), // Equal padding
                                    child: StackedAreaChart(
                                      xAxisTitle: '',
                                      yAxisTitle: 'Values',
                                      seriesData: [
                                        ChartData('Day 1', 3, 2, 1),
                                        ChartData('Day 2', 4, 3, 2),
                                        ChartData('Day 3', 2, 5, 3),
                                        ChartData('Day 4', 5, 2, 4),
                                        ChartData('Day 5', 3, 4, 2),
                                      ],
                                      seriesColors: [
                                        Colors.blue.withOpacity(0.6),
                                        Colors.green.withOpacity(0.6),
                                        Colors.red.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Graphs Section End
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeSeriesChart extends StatelessWidget {
  final List<TimeSeriesDataSet> dataSets;
  final bool showMarkers;
  final bool showArea;

  const TimeSeriesChart({
    super.key,
    required this.dataSets,
    this.showMarkers = true,
    this.showArea = false,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: const TextStyle(fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'series.name - point.x : point.y%',
        shared: true,
      ),
      primaryXAxis: DateTimeAxis(
        axisLine: const AxisLine(width: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      series: _buildSeries(),
    );
  }

  List<CartesianSeries<TimeSeriesData, DateTime>> _buildSeries() {
    return dataSets.map((dataSet) {
      if (showArea) {
        return SplineAreaSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          gradient: dataSet.gradient,
          borderColor: dataSet.color,
          borderWidth: 2,
          splineType: SplineType.cardinal,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
            color: dataSet.color,
          ),
        );
      } else {
        return SplineSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          color: dataSet.color,
          width: 2,
          splineType: SplineType.cardinal,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
            color: dataSet.color,
          ),
        );
      }
    }).toList();
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);
}

class TimeSeriesDataSet {
  final String name;
  final List<TimeSeriesData> data;
  final Color color;
  final LinearGradient? gradient;

  TimeSeriesDataSet({
    required this.name,
    required this.data,
    required this.color,
    this.gradient,
  });
}
