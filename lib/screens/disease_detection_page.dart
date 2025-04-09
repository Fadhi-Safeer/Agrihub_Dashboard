import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/elevated_info_card.dart';

class DIseaseDetectionPage extends StatefulWidget {
  const DIseaseDetectionPage({super.key});

  @override
  State<DIseaseDetectionPage> createState() => _DIseaseDetectionPageState();
}

class _DIseaseDetectionPageState extends State<DIseaseDetectionPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
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
                      children: const [
                        ElevatedInfoCard(
                          title: 'Early Growth',
                          image: 'assets/early_growth_icon.png',
                          number: 120,
                        ),
                        ElevatedInfoCard(
                          title: 'Leafy Growth',
                          image: 'assets/leafy_growth_icon.png',
                          number: 90,
                        ),
                        ElevatedInfoCard(
                          title: 'Head Formation',
                          image: 'assets/head_formation_icon.png',
                          number: 75,
                        ),
                        ElevatedInfoCard(
                          title: 'Harvest Stage',
                          image: 'assets/harvest_stage_icon.png',
                          number: 60,
                        ),
                      ],
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
