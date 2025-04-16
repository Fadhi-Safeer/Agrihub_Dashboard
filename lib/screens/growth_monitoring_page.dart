import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/elevated_card.dart';

class GrowthMonitoringPage extends StatelessWidget {
  const GrowthMonitoringPage({super.key});

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
                    'Plant Growth Monitoring',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),
                // Growth cards grid (fixed height, non-scrollable)
                SizedBox(
                  height: SizeConfig.proportionateScreenHeight(500),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height * 0.65),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      children: [
                        ElevatedCard.square(
                          title: 'Early Growth',
                          description: '120 Plants',
                          backgroundColor: Colors.lightGreen[300]!,
                          size: SizeConfig.proportionateScreenWidth(150),
                        ),
                        ElevatedCard.square(
                          title: 'Leafy Growth',
                          description: '90 Plants',
                          backgroundColor: Colors.green[400]!,
                          size: SizeConfig.proportionateScreenWidth(150),
                        ),
                        ElevatedCard.square(
                          title: 'Head Formation',
                          description: '75 Plants',
                          backgroundColor: Colors.amber[300]!,
                          size: SizeConfig.proportionateScreenWidth(150),
                        ),
                        ElevatedCard.square(
                          title: 'Harvest Stage',
                          description: '60 Plants',
                          backgroundColor: Colors.orange[400]!,
                          size: SizeConfig.proportionateScreenWidth(150),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fixed graph section
                Expanded(
                  flex: 3, // Slightly increase the graph section size
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0,
                        16.0), // Reduced top padding to decrease space above
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
