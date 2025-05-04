import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/elevated_card.dart';
import '../widgets/monitoring_pages/bullet_points_card.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';

class DiseaseDetectionPage extends StatefulWidget {
  const DiseaseDetectionPage({super.key});

  @override
  State<DiseaseDetectionPage> createState() => _DiseaseDetectionPageState();
}

class _DiseaseDetectionPageState extends State<DiseaseDetectionPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    child: CameraSelectionDropdown(),
                  ),
                  const SizedBox(height: 16.0),

                  // Analysis Section
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedCard(
                                title: 'Disease Analysis',
                                description:
                                    'Detailed analysis of diseases detected.',
                                showTopBar: true,
                              ),
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
                      child: ElevatedCard.elevated(
                        title: 'Graphs Section',
                        description:
                            'Display of analysis graphs related to growth, health, etc.',
                        backgroundColor: AppColors.cardBackground,
                        width:
                            double.infinity, // Set to fill the available width
                        heightMultiplier:
                            0.4, // Control the height relative to the width
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
