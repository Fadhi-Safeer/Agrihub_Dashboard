import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ImageCard.dart';
import '../models/image_item.dart';
import '../providers/health_status_provider.dart';
import '../providers/image_list_provider.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
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

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final galleryProvider = Provider.of<ImageListProvider>(context);
    final healthProvider = Provider.of<HealthStatusProvider>(context);

    // Filter out images with growth == "camera_view"
    final filteredImages = galleryProvider.images
        .where((imageItem) => imageItem.growth != "camera_view")
        .toList();

    // Update health status in provider
    healthProvider.updateStatus(filteredImages);

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

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
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
                    const SizedBox(height: 16),
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
                                  ),
                                ],
                              ),
                            ),
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
