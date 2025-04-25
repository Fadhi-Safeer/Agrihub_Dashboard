import 'package:flutter/material.dart';
import '../models/growth_stage.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/monitoring_pages/health_card_grid.dart';
import '../widgets/monitoring_pages/elevated_image_card.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';

class HealthAnalysisPage extends StatefulWidget {
  const HealthAnalysisPage({super.key});

  @override
  State<HealthAnalysisPage> createState() => _HealthAnalysisPageState();
}

class _HealthAnalysisPageState extends State<HealthAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final List<GrowthStage> growthStages = List.generate(
      14,
      (index) => GrowthStage(
        title: 'Crop ${index + 1}',
        color: AppColors.cardBackground,
        slotImages:
            List.filled(2, 'assets/harvest_stage_icon.png'), // Default images
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(), // Sidebar widget
          Expanded(
            child: Column(
              children: [
                // Top Heading
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Health Analysis',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),
                // Dropdown Menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CameraSelectionDropdown(),
                ),
                const SizedBox(height: 16.0), // Add spacing

                // HealthCardGrid with ElevatedImageCard
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: HealthCardGrid(
                      n: growthStages.length, // Total number of cards
                      rows: 2, // Maximum 2 rows
                      childBuilder: (index) {
                        return ElevatedImageCard(stage: growthStages[index]);
                      },
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
