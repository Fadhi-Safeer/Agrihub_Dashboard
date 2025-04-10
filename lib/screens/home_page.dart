import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../widgets/monitoring_pages/elevated_card.dart';
import '../widgets/navigation_sidebar.dart'; // Import the NavigationSidebar widget

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double availableHeight =
        MediaQuery.of(context).size.height; // Total screen height
    final double squareSize =
        availableHeight / 4.8; // Calculate square size for the cards
    final double boxHeight = squareSize * 2;
    final double imageSize = boxHeight * 2 / 5; // 2/5 of the box height

    return Scaffold(
      body: Row(
        children: [
          // Navigation Sidebar
          const NavigationSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Heading (Updated with consistent style)
                Padding(
                  padding:
                      const EdgeInsets.all(16.0), // Padding around the heading
                  child: Text(
                    'Agricultural Growth & Research with AI Vision', // Updated heading text
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart, // Custom color
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                        8), // Padding around the entire scrollable content
                    child: Column(
                      children: [
                        /// TOP ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      8), // Padding around the left column (horizontal only)
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: 'Healthy Plants Detected',
                                    description: '248',
                                    backgroundColor: Colors.green[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(
                                      height:
                                          8), // Spacing between cards in the left column
                                  ElevatedCard.square(
                                    title: 'Plants in Growth Stage 3',
                                    description: '75',
                                    backgroundColor: Colors.teal[200]!,
                                    size: squareSize,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width:
                                    8), // Spacing between the left column and the middle section

                            // Middle Expanded Description Text
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: (squareSize * 2) + 6,
                                padding: const EdgeInsets.all(
                                    16), // Padding inside the middle container
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: const SingleChildScrollView(
                                  child: Text(
                                    'AgriVision AI is an intelligent plant monitoring system developed under APCore (Asia Pacific Center of Robotics Engineering), focused on optimizing the growth and health of hydroponic crops, '
                                    'starting with lettuce at the University Agrihub Lab. It leverages deep learning models to perform real-time detection and '
                                    'classification of plant growth stages, health status, and potential diseases using live CCTV feeds. Designed for precision '
                                    'agriculture, the system supports non-soil-based farming by providing continuous visual monitoring, early issue detection, and '
                                    'data-driven insights through a Flutter-based dashboard and Python FastAPI backend. AgriVision AI enables remote access, automated '
                                    'data analysis, and cloud storage, making it a scalable solution for modern hydroponic farming environments.',
                                    style: TextStyle(fontSize: 14, height: 1.5),
                                    textAlign: TextAlign.justify,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                                width:
                                    8), // Spacing between the middle section and the right column

                            // Right column
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      8), // Padding around the right column (horizontal only)
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: 'Unhealthy/Diseased Plants',
                                    description: '12',
                                    backgroundColor: Colors.red[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(
                                      height:
                                          8), // Spacing between cards in the right column
                                  ElevatedCard.square(
                                    title: 'Model Accuracy',
                                    description: '92%',
                                    backgroundColor: Colors.deepPurple[300]!,
                                    size: squareSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                            height:
                                8), // Spacing between the top row and the bottom row

                        /// BOTTOM ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      8), // Padding around the left column (horizontal only)
                              child: Column(
                                children: [
                                  ElevatedCard.square(
                                    title: "Today's Detection Count",
                                    description: '1,120',
                                    backgroundColor: Colors.blueGrey[300]!,
                                    size: squareSize,
                                  ),
                                  const SizedBox(
                                      height:
                                          8), // Spacing between cards in the left column
                                  ElevatedCard.square(
                                    title: 'Avg. Detection Time',
                                    description: '0.15 sec',
                                    backgroundColor: Colors.cyan[300]!,
                                    size: squareSize,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width:
                                    8), // Spacing between the left column and the middle card

                            // Slightly smaller middle card
                            Expanded(
                              flex: 2,
                              child: ElevatedCard(
                                title: 'Audience Growth (Bar Chart)',
                                description: '5000',
                                backgroundColor: Colors.purple[200]!,
                                width: squareSize,
                                height: (squareSize * 2) +
                                    6, // Custom height calculation
                              ),
                            ),
                            const SizedBox(
                                width:
                                    16), // Spacing between the middle card and the right column

                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/agrivision');
                                },
                                child: Container(
                                  height: boxHeight,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Centered Text
                                      Align(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Live Monitoring'),
                                            Text(
                                                'Click to view real-time plant detection',
                                                style:
                                                    TextStyles.modern.copyWith(
                                                  fontSize: 16,
                                                  color: AppColors
                                                      .sidebarGradientStart,
                                                )),
                                          ],
                                        ),
                                      ),

                                      // Camera Icon (Top-Right)
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: Image.asset(
                                          'assets/camera.png',
                                          width:
                                              imageSize, // Use imageSize to control the size
                                          height: imageSize,
                                        ),
                                      ),

                                      // Image (Left-aligned, cropped on right)
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32, // Full width minus padding (16 * 2)
                                          height: boxHeight *
                                              2 /
                                              5, // 2/5 of the height
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/plant.png'),
                                              fit: BoxFit
                                                  .cover, // Crop the right side and keep the left part
                                              alignment: Alignment
                                                  .centerLeft, // Ensure the left part is always visible
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Right column
                          ],
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
