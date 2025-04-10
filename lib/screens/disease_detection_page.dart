import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';

class DiseaseDetectionPage extends StatelessWidget {
  const DiseaseDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.monitoring_pages_background,
      body: Row(
        children: [
          const NavigationSidebar(), // Sidebar widget
          Expanded(
            child: Center(
              // Center the entire content
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                children: [
                  // Disease Detection Heading
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Disease Detection',
                      style: TextStyles.mainHeading.copyWith(
                        color: AppColors.sidebarGradientStart,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  // Dropdown Menu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppColors.sidebarGradientStart,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        value: 'Option 1', // Default selected value
                        onChanged: (String? newValue) {
                          // Handle dropdown selection
                        },
                        items: <String>['Option 1', 'Option 2', 'Option 3']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                color: AppColors.sidebarGradientStart,
                              ),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0), // Add spacing
                  // Grid with 3/4 and 1/4 layout
                  SizedBox(
                    height: SizeConfig.proportionateScreenHeight(500),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                      child: Row(
                        children: [
                          // Left 3/4 Section
                          Expanded(
                            flex: 3, // 3/4 of the width
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomInfoCard(
                                title: 'Disease Analysis',
                                description:
                                    'Detailed analysis of diseases detected.',
                                backgroundColor: AppColors.cardBackground,
                              ),
                            ),
                          ),
                          // Right 1/4 Section
                          Expanded(
                            flex: 1, // 1/4 of the width
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
          ),
        ],
      ),
    );
  }
}

/// A reusable widget for a card with a title and description.
class CustomInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;

  const CustomInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.mainHeading.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable widget for a card displaying bullet points with square bullets.
class BulletPointsCard extends StatelessWidget {
  final String title;
  final List<String> bulletPoints;
  final List<Color> bulletColors;

  const BulletPointsCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    required this.bulletColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.mainHeading.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8.0),
            ...bulletPoints.asMap().entries.map((entry) {
              int index = entry.key;
              String point = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(right: 8.0, top: 4.0),
                      decoration: BoxDecoration(
                        color: bulletColors[index % bulletColors.length],
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
