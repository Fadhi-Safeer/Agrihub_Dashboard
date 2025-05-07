import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Disease Detection',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
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
                // Graphs Section
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
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            'Graphs Section',
                            style: TextStyles.elevatedCardTitle,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Display of analysis graphs related to growth, health, etc.',
                                style: TextStyles.elevatedCardDescription,
                                textAlign: TextAlign.center,
                              ),
                            ),
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
    );
  }
}
