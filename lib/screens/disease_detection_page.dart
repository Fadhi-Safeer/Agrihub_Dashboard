import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ImageCard.dart';
import '../providers/image_list_provider.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';

import '../widgets/graphs/time_series_chart.dart';
import '../widgets/graphs/donut_chart.dart';
import '../widgets/graphs/combination_chart.dart';

import '../widgets/monitoring_pages/graph_section.dart';
import '../widgets/monitoring_pages/health_card_grid.dart';
import '../widgets/monitoring_pages/elevated_image_card.dart';
import '../widgets/monitoring_pages/health_status_bulb.dart';
import '../widgets/monitoring_pages/top_bard.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  bool _isGridExpanded = false;

  bool _isHealthyDiseaseLabel(String? diseaseLabel) {
    final d = (diseaseLabel ?? '').trim().toLowerCase();
    return d == 'healthy';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final galleryProvider = Provider.of<ImageListProvider>(context);

    // Filter out camera_view items (same logic style as health page)
    final filteredImages = galleryProvider.images
        .where((imageItem) => imageItem.growth != "camera_view")
        .toList();

    // Status bulb (green = all healthy, red = any disease present)
    final bool allHealthy = filteredImages.isEmpty
        ? true
        : filteredImages.every((img) => _isHealthyDiseaseLabel(img.disease));

    // Convert images to ImageCard grid
    final List<ImageCard> imageCards =
        filteredImages.asMap().entries.map((entry) {
      final index = entry.key;
      final imageItem = entry.value;

      return ImageCard(
        title: 'Crop ${index + 1}',
        color: AppColors.cardBackground,
        slotImages: [imageItem.url],
        description: imageItem.disease, // ✅ disease shown under card
      );
    }).toList();

    // Fallback cards
    final displayCards = imageCards.isNotEmpty
        ? imageCards
        : List.generate(
            14,
            (index) => ImageCard(
              title: 'Crop ${index + 1}',
              color: AppColors.cardBackground,
              slotImages: const ['assets/harvest_stage_icon.png'],
            ),
          );

    // Graphs (same section style as health page)
    final List<Widget> diseaseGraphs = [
      TimeSeriesChart(
        dataSets: [
          TimeSeriesDataSet(
            name: 'Disease Rate (%)',
            data: [
              TimeSeriesData(DateTime(2025, 5, 1), 3.2),
              TimeSeriesData(DateTime(2025, 5, 8), 3.8),
              TimeSeriesData(DateTime(2025, 5, 15), 4.2),
              TimeSeriesData(DateTime(2025, 5, 22), 3.9),
              TimeSeriesData(DateTime(2025, 5, 29), 3.6),
            ],
            color: Colors.red,
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.30),
                Colors.red.withOpacity(0.10),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ],
        showMarkers: true,
        showArea: false,
      ),
      DonutChart(
        data: [
          DonutChartData('Downy Mildew', 2, Colors.blue),
          DonutChartData('Bacterial', 8, Colors.orange),
          DonutChartData('Septoria Blight', 10, Colors.red),
          DonutChartData('Healthy', 75, Colors.green),
        ],
        title: 'Disease Detected',
        showLegend: true,
        showLabels: true,
        enableTooltip: true,
      ),
      CombinationChart(
        data: [
          CombinationChartData('Week 1', 3.5, 26.0),
          CombinationChartData('Week 2', 4.1, 27.5),
          CombinationChartData('Week 3', 4.8, 29.0),
          CombinationChartData('Week 4', 4.0, 28.0),
          CombinationChartData('Week 5', 3.6, 27.0),
          CombinationChartData('Week 6', 3.9, 26.5),
        ],
        title: "Disease Rate vs Temperature",
        xAxisTitle: "Time Period",
        yAxisTitle: "Disease Rate (%)",
      ),
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
                // TopBar + Status bulb (same layout as HealthAnalysisPage)
                Stack(
                  children: [
                    TopBar(
                      title: 'Disease Detection',
                      textStyle: TextStyles.mainHeading.copyWith(
                        color: AppColors.sidebarGradientStart,
                      ),
                      bulbSize: 30,
                    ),
                    Positioned(
                      right: 16,
                      top: 16,
                      child: HealthStatusLight(
                        // reusing the same bulb widget
                        isHealthy: allHealthy,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Camera dropdown (same placement as HealthAnalysisPage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(
                    onCameraChanged: (selectedCamera) {
                      // same behavior as your old disease page
                      Provider.of<ImageListProvider>(context, listen: false)
                          .loadImages(selectedCamera, camera_view: true);
                    },
                  ),
                ),

                const SizedBox(height: 16.0),

                Expanded(
                  child: Column(
                    children: [
                      // Grid (expand/collapse like health page)
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

                      // Graphs section (only when grid is NOT expanded)
                      if (!_isGridExpanded)
                        Expanded(
                          flex: 2,
                          child: GraphsSection(
                            title: 'Disease Analytics',
                            graphs: diseaseGraphs,
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
