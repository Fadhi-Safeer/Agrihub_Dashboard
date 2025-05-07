import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../../utils/size_config.dart';
import '../../widgets/navigation_sidebar.dart';
import '../../widgets/monitoring_pages/camera_selection_dropdown.dart';
import '../../widgets/monitoring_pages/infobox_overlay.dart';
import '../../providers/image_list_provider.dart';
import '../../models/ImageCard.dart';
import '../../widgets/monitoring_pages/elevated_image_card.dart';

class GrowthMonitoringPage extends StatefulWidget {
  const GrowthMonitoringPage({super.key});

  @override
  State<GrowthMonitoringPage> createState() => _GrowthMonitoringPageState();
}

class _GrowthMonitoringPageState extends State<GrowthMonitoringPage> {
  bool isOverlayVisible = false;
  String selectedCamera = '';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final galleryProvider = Provider.of<ImageListProvider>(context);

    // Group images by growth stage, collecting URLs instead of widget instances
    Map<String, List<String>> groupedImageUrls = {
      'early growth': [],
      'leafy growth': [],
      'head formation': [],
      'harvest stage': [],
    };

    for (var item in galleryProvider.images) {
      final stage = item.growth.toLowerCase().trim();
      if (groupedImageUrls.containsKey(stage)) {
        groupedImageUrls[stage]!.add(item.url);
      }
    }

    // Descriptions for each growth stage
    final Map<String, String> stageDescriptions = {
      'early growth': 'First few weeks of plant development',
      'leafy growth': 'Period of rapid leaf expansion',
      'head formation': 'Development of the central head/fruit',
      'harvest stage': 'Plants ready for harvest',
    };

    // Calculate total number of images across all stages
    int totalImageCount =
        groupedImageUrls.values.fold(0, (sum, urls) => sum + urls.length);

    // Create ImageCard models for each growth stage
    final List<ImageCard> imageCardModels = [
      ImageCard(
        title: 'Early Growth',
        description: stageDescriptions['early growth']!,
        color: Colors.lightGreen[300]!,
        slotCount: totalImageCount,
        slotImages: groupedImageUrls['early growth']!.isEmpty
            ? []
            : groupedImageUrls['early growth']!,
      ),
      ImageCard(
        title: 'Leafy Growth',
        description: stageDescriptions['leafy growth']!,
        color: Colors.green[400]!,
        slotCount: totalImageCount,
        slotImages: groupedImageUrls['leafy growth']!.isEmpty
            ? []
            : groupedImageUrls['leafy growth']!,
      ),
      ImageCard(
        title: 'Head Formation',
        description: stageDescriptions['head formation']!,
        color: Colors.amber[300]!,
        slotCount: totalImageCount,
        slotImages: groupedImageUrls['head formation']!.isEmpty
            ? []
            : groupedImageUrls['head formation']!,
      ),
      ImageCard(
        title: 'Harvest Stage',
        description: stageDescriptions['harvest stage']!,
        color: Colors.orange[400]!,
        slotCount: totalImageCount,
        slotImages: groupedImageUrls['harvest stage']!.isEmpty
            ? []
            : groupedImageUrls['harvest stage']!,
      ),
    ];

    // Create ElevatedImageCard widgets using the models
    final List<Widget> imageCards = imageCardModels
        .map((model) => ElevatedImageCard(stage: model))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Plant Growth Monitoring',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(
                    onCameraChanged: (cameraId) {
                      setState(() => selectedCamera = cameraId);
                      galleryProvider.loadImages(cameraId);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Main content: 2x2 grid of image cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: imageCards[0]),
                                  const SizedBox(width: 16),
                                  Expanded(child: imageCards[1]),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(child: imageCards[2]),
                                  const SizedBox(width: 16),
                                  Expanded(child: imageCards[3]),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Center Info Button
                        Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              size: 40,
                              color: AppColors.sidebarGradientStart,
                            ),
                            onPressed: () {
                              setState(() {
                                isOverlayVisible = true;
                              });
                            },
                          ),
                        ),

                        // Info Overlay
                        if (isOverlayVisible)
                          InfoBoxOverlay(
                            onClose: () {
                              setState(() {
                                isOverlayVisible = false;
                              });
                            },
                          ),
                      ],
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
