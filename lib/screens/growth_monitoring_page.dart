import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../../utils/size_config.dart';
import '../../widgets/navigation_sidebar.dart';
import '../../widgets/monitoring_pages/camera_selection_dropdown.dart';
import '../widgets/monitoring_pages/elevated_image_card.dart';
import '../../widgets/monitoring_pages/infobox_overlay.dart';
import '../models/ElevatedImageCard.dart';

class GrowthMonitoringPage extends StatefulWidget {
  const GrowthMonitoringPage({super.key});

  @override
  State<GrowthMonitoringPage> createState() => _GrowthMonitoringPageState();
}

class _GrowthMonitoringPageState extends State<GrowthMonitoringPage> {
  final List<ImageCard> imageCards = [
    ImageCard(
      title: 'Early Growth',
      color: Colors.lightGreen[300]!,
      slotCount: 12,
      slotImages: ['assets/leafy_growth_icon.png'],
    ),
    ImageCard(
      title: 'Leafy Growth',
      color: Colors.green[400]!,
      slotCount: 12,
      slotImages: ['assets/leafy_growth_icon.png'],
    ),
    ImageCard(
      title: 'Head Formation',
      color: Colors.amber[300]!,
      slotCount: 12,
      slotImages: ['assets/leafy_growth_icon.png'],
    ),
    ImageCard(
      title: 'Harvest Stage',
      color: Colors.orange[400]!,
      slotCount: 1,
      slotImages: ['assets/leafy_growth_icon.png'],
    ),
  ];

  bool isOverlayVisible = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Plant Growth Monitoring',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),

                // Camera Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(),
                ),
                const SizedBox(height: 16),

                // Main Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        // Background Grid with Growth Cards
                        Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child:
                                        ElevatedImageCard(stage: imageCards[0]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child:
                                        ElevatedImageCard(stage: imageCards[1]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child:
                                        ElevatedImageCard(stage: imageCards[2]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child:
                                        ElevatedImageCard(stage: imageCards[3]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Center Info Icon Button
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

                        // Overlay
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
