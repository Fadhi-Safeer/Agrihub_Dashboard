import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/elevated_cards_grid.dart';

class HealthAnalysisPage extends StatelessWidget {
  const HealthAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

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
                // Health cards grid (dynamic number of boxes in 2 rows)
                SizedBox(
                  height: SizeConfig.proportionateScreenHeight(500),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                    child: InfoCardsGrid(
                      n: 14, // Example: Display 14 cards
                    ),
                  ),
                ),
                // Fixed graph section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: AppColors.cardBackground,
                      child: Center(
                        child: Text(
                          'Graphs Section',
                          style: TextStyles.graphSectionTitle,
                        ),
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
