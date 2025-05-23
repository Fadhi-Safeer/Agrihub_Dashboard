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
            name: 'Nitrogen',
            data: [
              TimeSeriesData(DateTime(2025, 4, 1), 35),
              TimeSeriesData(DateTime(2025, 4, 8), 45),
              TimeSeriesData(DateTime(2025, 4, 15), 60),
              TimeSeriesData(DateTime(2025, 4, 22), 70),
              TimeSeriesData(DateTime(2025, 4, 29), 65),
            ],
            color: const Color(0xFF00C851), // Vibrant Green
            gradient: LinearGradient(
              colors: [const Color(0xFF00C851), const Color(0xFF7ED321)],
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
            color: const Color(0xFF2196F3), // Vibrant Blue
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
            color: const Color(0xFFFF6B35), // Vibrant Orange
          ),
        ],
        showMarkers: true,
        showArea: false,
      ),

      // Health Distribution
      RadarChart(
        data: [
          RadarChartData(label: "Growth", value: 0.8),
          RadarChartData(label: "Health", value: 0.6),
          RadarChartData(label: "Nutrients", value: 0.9),
          RadarChartData(label: "Moisture", value: 0.7),
          RadarChartData(label: "Light", value: 0.5),
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

      CombinationChart(data: [
        CombinationChartData('Week 1', 6.5, 15),
        CombinationChartData('Week 2', 6.3, 20),
        CombinationChartData('Week 3', 6.7, 35),
        CombinationChartData('Week 4', 7.0, 30),
        CombinationChartData('Week 5', 6.8, 26),
        CombinationChartData('Week 6', 6.8, 28),
      ])
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

// Data classes for the charts
class NutritionData {
  final String week;
  final double value;

  NutritionData(this.week, this.value);
}

class HealthData {
  final String category;
  final double percentage;
  final Color color;

  HealthData(this.category, this.percentage, this.color);
}

class WaterData {
  final String day;
  final double waterUsage;
  final double phLevel;

  WaterData(this.day, this.waterUsage, this.phLevel);
}
