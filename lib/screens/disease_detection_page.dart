import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/graphs/area_chart.dart';
import '../widgets/graphs/donut_chart.dart';
import '../widgets/graphs/time_series_chart.dart';
import '../widgets/monitoring_pages/graph_section.dart';
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

    // Define the graphs that will be displayed in the graphs section
    final List<Widget> diseaseGraphs = [
      // Disease rate over time chart
      TimeSeriesChart(
        dataSets: [
          TimeSeriesDataSet(
            name: 'Disease Rate',
            data: [
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 21)), 45),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 14)), 65),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 7)), 35),
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

      // Weather Correlation Graph
      StackedAreaChart(
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

// Growth Stage Distribution (custom_pie_chart.dart)
      DonutChart(
        data: [
          DonutChartData('Early Growth', 25, Colors.blue),
          DonutChartData('Leafy Growth', 38, Colors.green),
          DonutChartData('Head Formation', 12, Colors.red),
          DonutChartData('Harvest Stage', 25, Colors.orange),
        ],
        title: 'Plant Growth Stages',
        showLegend: true,
        showLabels: true,
        enableTooltip: true,
      ),
    ];

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

                // Graphs Section using the new GraphsSection widget
                Expanded(
                  flex: 2,
                  child: Expanded(
                    child: GraphsSection(
                      title: 'Growth Analytics',
                      graphs: diseaseGraphs,
                      height: double.infinity,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
