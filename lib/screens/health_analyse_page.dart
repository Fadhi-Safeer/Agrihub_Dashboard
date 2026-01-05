import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ImageCard.dart';
import '../providers/health_status_provider.dart';
import '../providers/image_list_provider.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/graphs/combination_chart.dart';
import '../widgets/graphs/radar_chart.dart';
import '../widgets/graphs/time_series_chart.dart';
import '../widgets/monitoring_pages/graph_section.dart';
import '../widgets/monitoring_pages/health_card_grid.dart';
import '../widgets/monitoring_pages/elevated_image_card.dart';
import '../widgets/monitoring_pages/health_status_bulb.dart';
import '../widgets/monitoring_pages/top_bard.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';

class HealthAnalysisPage extends StatefulWidget {
  const HealthAnalysisPage({super.key});

  @override
  State<HealthAnalysisPage> createState() => _HealthAnalysisPageState();
}

class _HealthAnalysisPageState extends State<HealthAnalysisPage> {
  bool _isGridExpanded = false;
  bool _isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    // Schedule an update for after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHealthStatus();
    });
  }

  void _updateHealthStatus() {
    // Safely update the health provider outside of the build or dependency cycle
    if (!mounted) return;

    final galleryProvider =
        Provider.of<ImageListProvider>(context, listen: false);
    final healthProvider =
        Provider.of<HealthStatusProvider>(context, listen: false);

    // Filter out images with growth == "camera_view"
    final filteredImages = galleryProvider.images
        .where((imageItem) => imageItem.growth != "camera_view")
        .toList();

    // Update health status in provider
    healthProvider.updateStatus(filteredImages);
  }

  @override
  void didUpdateWidget(HealthAnalysisPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Schedule update after the frame is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHealthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final galleryProvider = Provider.of<ImageListProvider>(context);

    // Check if we need to update on first build
    if (_isFirstBuild) {
      _isFirstBuild = false;
      // Schedule an update after this frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateHealthStatus();
      });
    }

    // Filter out images with growth == "camera_view"
    final filteredImages = galleryProvider.images
        .where((imageItem) => imageItem.growth != "camera_view")
        .toList();

    // Convert filtered images to ImageCard format
    final List<ImageCard> imageCards =
        filteredImages.asMap().entries.map((entry) {
      final index = entry.key;
      final imageItem = entry.value;

      return ImageCard(
        title: 'Crop ${index + 1}',
        color: AppColors.cardBackground,
        slotImages: [imageItem.url],
        description: imageItem.health,
      );
    }).toList();

    // Fallback to default cards if no images are loaded
    final displayCards = imageCards.isNotEmpty
        ? imageCards
        : List.generate(
            14,
            (index) => ImageCard(
              title: 'Crop ${index + 1}',
              color: AppColors.cardBackground,
              slotImages: ['assets/harvest_stage_icon.png'],
            ),
          );

// Define the health analysis graphs
    final List<Widget> healthGraphs = [
      TimeSeriesChart(
        dataSets: [
          TimeSeriesDataSet(
            name: 'Growth Rate (%)',
            data: [
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 28)), 15.2),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 21)), 28.7),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 14)), 45.3),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 7)), 62.8),
              TimeSeriesData(DateTime.now(), 78.5),
            ],
            color: Colors.green,
            gradient: LinearGradient(
              colors: [
                Colors.green.withOpacity(0.3),
                Colors.green.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          TimeSeriesDataSet(
            name: 'Humidity (%)',
            data: [
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 28)), 62.0),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 21)), 65.5),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 14)), 68.2),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 7)), 64.8),
              TimeSeriesData(DateTime.now(), 61.3),
            ],
            color: Colors.blue,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          TimeSeriesDataSet(
            name: 'Water Level (%)',
            data: [
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 28)), 85.0),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 21)), 78.5),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 14)), 72.2),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 7)), 68.8),
              TimeSeriesData(DateTime.now(), 65.3),
            ],
            color: Colors.cyan,
            gradient: LinearGradient(
              colors: [
                Colors.cyan.withOpacity(0.3),
                Colors.cyan.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          TimeSeriesDataSet(
            name: 'Health Score (%)',
            data: [
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 28)), 70.1),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 21)), 73.3),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 14)), 76.5),
              TimeSeriesData(
                  DateTime.now().subtract(const Duration(days: 7)), 74.4),
              TimeSeriesData(DateTime.now(), 72.2),
            ],
            color: Colors.orange,
            gradient: LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.3),
                Colors.orange.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
        showMarkers: true,
        showArea: false,
      ),

      // Health Distribution
      RadarChart(
        data: [
          RadarChartData(label: "Nitrogen", value: 0.75),
          RadarChartData(label: "Phosphorus", value: 0.65),
          RadarChartData(label: "Potassium", value: 0.70),
          RadarChartData(label: "Calcium", value: 0.55),
          RadarChartData(label: "Magnesium", value: 0.60),
          RadarChartData(label: "Iron", value: 0.50),
        ],
        fillColor:
            const Color(0xFFFF6B35).withOpacity(0.3), // Vibrant Pink fill
        borderColor: const Color(0xFFE91E63), // Vibrant Pink border
        gridColor: Colors.grey.withOpacity(0.3),
        labelColor: const Color(0xFF424242), // Dark grey for readability
        divisions: 5,
        labelFontSize: 14,
        borderWidth: 2.0,
        gridWidth: 1.0,
        showLabels: true,
        animate: true,
        animationDuration: 800,
      ),

      CombinationChart(
        data: [
          CombinationChartData('Week 1', 78.5, 26.2),
          CombinationChartData('Week 2', 72.1, 28.5),
          CombinationChartData('Week 3', 68.9, 29.8),
          CombinationChartData('Week 4', 75.3, 27.1),
          CombinationChartData('Week 5', 81.2, 25.9),
          CombinationChartData('Week 6', 77.8, 26.8),
          CombinationChartData('Week 7', 73.4, 28.2),
          CombinationChartData('Week 8', 79.6, 26.5),
        ],
        title: "Environmental Factors vs Plant Health",
        xAxisTitle: "Time Period",
        yAxisTitle: "Health Score (%)",
      )
    ];

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    TopBar(
                      title: 'Health Analysis',
                      textStyle: TextStyles.mainHeading.copyWith(
                        color: AppColors.sidebarGradientStart,
                      ),
                      bulbSize: 30,
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: Consumer<HealthStatusProvider>(
                        builder: (context, healthProvider, _) {
                          return HealthStatusLight(
                            isHealthy: healthProvider.allFullyNutritional,
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(
                    onCameraChanged: (selectedCamera) {
                      Provider.of<ImageListProvider>(context, listen: false)
                          .loadImages(selectedCamera);
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: _isGridExpanded ? 1 : 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: HealthCardGrid(
                            n: displayCards.length,
                            childBuilder: (index) =>
                                ElevatedImageCard(stage: displayCards[index]),
                            isExpanded: _isGridExpanded,
                            onToggleExpand: () => setState(
                                () => _isGridExpanded = !_isGridExpanded),
                          ),
                        ),
                      ),
                      if (!_isGridExpanded)
                        Expanded(
                          flex: 2,
                          // This is the only part that's changed - replacing the Container with GraphsSection
                          child: GraphsSection(
                            title: 'Health Analysis Trends',
                            graphs: healthGraphs,
                            padding: const EdgeInsets.all(16.0),
                          ),
                        ),
                    ],
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
