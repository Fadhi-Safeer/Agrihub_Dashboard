import 'package:flutter/material.dart';
import '../widgets/monitoring_pages/elevated_info_card.dart';
import '../widgets/navigation_sidebar.dart'; // Import the NavigationSidebar widget

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double availableHeight =
        MediaQuery.of(context).size.height; // Total screen height
    final double squareSize =
        availableHeight / 4.6; // Calculate square size for the cards

    return Scaffold(
      body: Row(
        children: [
          // Navigation Sidebar
          const NavigationSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                AppBar(
                  title: const Text(
                    'Agricultural Growth & Research with AI Vision',
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        /// TOP ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Column(
                              children: [
                                _buildSquareInfoCard(
                                  title: 'Facebook Likes',
                                  number: 3009,
                                  backgroundColor: Colors.indigo[100]!,
                                  size: squareSize,
                                ),
                                const SizedBox(height: 4),
                                _buildSquareInfoCard(
                                  title: 'YouTube Subscribers',
                                  number: 342,
                                  backgroundColor: Colors.indigo[200]!,
                                  size: squareSize,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),

                            // Middle Expanded Description Text
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: squareSize * 2,
                                padding: const EdgeInsets.all(16),
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
                                    'AgriVision AI is an intelligent plant monitoring system focused on optimizing the growth and health of hydroponic crops, '
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

                            const SizedBox(width: 4),

                            // Right column
                            Column(
                              children: [
                                _buildSquareInfoCard(
                                  title: 'Google Rankings',
                                  number: 25,
                                  backgroundColor: Colors.indigo[300]!,
                                  size: squareSize,
                                ),
                                const SizedBox(height: 4),
                                _buildSquareInfoCard(
                                  title: 'Trust Flow',
                                  number: 90,
                                  backgroundColor: Colors.indigo[400]!,
                                  size: squareSize,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// BOTTOM ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Column(
                              children: [
                                _buildSquareInfoCard(
                                  title: 'LinkedIn Followers',
                                  number: 143,
                                  backgroundColor: Colors.indigo[500]!,
                                  size: squareSize,
                                ),
                                const SizedBox(height: 4),
                                _buildSquareInfoCard(
                                  title: 'Twitter Followers',
                                  number: 3111,
                                  backgroundColor: Colors.indigo[600]!,
                                  size: squareSize,
                                ),
                              ],
                            ),
                            const SizedBox(width: 4),

                            // Slightly smaller middle card
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: squareSize * 2,
                                child: ElevatedInfoCard(
                                  title: 'Audience Growth (Bar Chart)',
                                  number: 5000,
                                  backgroundColor: Colors.purple[200]!,
                                  heightMultiplier:
                                      squareSize * 2 / 120, // Double height
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Right expanded to fill space
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to AgriVision page
                                  Navigator.pushNamed(context, '/agrivision');
                                },
                                child: Container(
                                  height: squareSize * 2,
                                  padding: const EdgeInsets.all(12),
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
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Go to AgriVision Page',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Image.asset(
                                          'assets/arrow.png',
                                          width: 60,
                                          height: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

  /// Helper method to build square info cards
  Widget _buildSquareInfoCard({
    required String title,
    required int number,
    required Color backgroundColor,
    required double size,
  }) {
    return Container(
      width: size + 0.3 * size,
      height: size,
      child: ElevatedInfoCard(
        title: title,
        number: number,
        backgroundColor: backgroundColor,
        heightMultiplier: size / 120, // Ensures the card is square
      ),
    );
  }
}
