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

                            // Middle Expanded card
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: squareSize * 2,
                                child: ElevatedInfoCard(
                                  title: 'Website Visitors (Pie Chart)',
                                  number: 8500,
                                  backgroundColor: Colors.purple[100]!,
                                  heightMultiplier:
                                      squareSize * 2 / 120, // Double height
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
                              child: Container(
                                height: squareSize * 2,
                                child: ElevatedInfoCard(
                                  title: 'AdWords Conversions',
                                  number: 350,
                                  backgroundColor: Colors.grey[300]!,
                                  heightMultiplier:
                                      squareSize * 2 / 120, // Double height
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
