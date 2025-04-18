import 'dart:math';

import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/camera_selection_dropdown.dart';

class GrowthMonitoringPage extends StatefulWidget {
  const GrowthMonitoringPage({super.key});

  @override
  State<GrowthMonitoringPage> createState() => _GrowthMonitoringPageState();
}

class _GrowthMonitoringPageState extends State<GrowthMonitoringPage> {
  final List<Map<String, dynamic>> growthStages = [
    {
      'title': 'Early Growth',
      'count': '120 Plants',
      'color': Colors.lightGreen[300]!,
      'slotCount': 12,
      'slotImages': [
        'assets/plant1.png',
        'assets/plant2.png',
        null, // Empty slot
        'assets/plant4.png',
        // Add more images or null for empty slots
      ],
    },
    {
      'title': 'Leafy Growth',
      'count': '90 Plants',
      'color': Colors.green[400]!,
      'slotCount': 8,
      'slotImages': [
        'assets/plant1.png',
        null,
        null,
        'assets/plant4.png',
      ],
    },
    {
      'title': 'Head Formation',
      'count': '75 Plants',
      'color': Colors.amber[300]!,
      'slotCount': 6,
      'slotImages': [
        'assets/plant1.png',
        null,
        'assets/plant3.png',
      ],
    },
    {
      'title': 'Harvest Stage',
      'count': '60 Plants',
      'color': Colors.orange[400]!,
      'slotCount': 4,
      'slotImages': [
        'assets/plant1.png',
        'assets/plant2.png',
      ],
    },
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
                                    child: _buildGrowthCard(growthStages[0]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildGrowthCard(growthStages[1]),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildGrowthCard(growthStages[2]),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildGrowthCard(growthStages[3]),
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

                        // Overlay (unchanged from previous implementation)
                        if (isOverlayVisible)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isOverlayVisible = false;
                              });
                            },
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardBackground,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Growth Summary',
                                          style: TextStyles.elevatedCardTitle,
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Total Plants: 345',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Average Growth Rate: 78%',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 5),
                                        const Text(
                                          'Next Harvest: 12 days',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.lightGreen[300]!,
                                                Colors.green[400]!,
                                                Colors.amber[300]!,
                                                Colors.orange[400]!,
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(Map<String, dynamic> stage) {
    final int slotCount = stage['slotCount'] ?? 12;
    final List<String?> slotImages =
        (stage['slotImages'] as List<dynamic>?)?.cast<String?>() ?? [];
    final int itemsPerRow = (slotCount / 2).ceil(); // Split slots into 2 rows

    return Container(
      decoration: BoxDecoration(
        color: stage['color'],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Title and Count
          Text(
            stage['title'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stage['count'],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Slot Grid
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // First row of slots
                Expanded(
                  child: _buildSlotRow(
                    startIndex: 0,
                    itemCount: itemsPerRow,
                    totalItems: slotCount,
                    slotImages: slotImages,
                  ),
                ),
                // Second row of slots
                Expanded(
                  child: _buildSlotRow(
                    startIndex: itemsPerRow,
                    itemCount: min(itemsPerRow, slotCount - itemsPerRow),
                    totalItems: slotCount,
                    slotImages: slotImages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotRow({
    required int startIndex,
    required int itemCount,
    required int totalItems,
    required List<String?> slotImages,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(itemCount, (index) {
        final slotIndex = startIndex + index;
        final imagePath =
            slotIndex < slotImages.length ? slotImages[slotIndex] : null;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: AspectRatio(
              aspectRatio: 1, // Square slots
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.crop_square,
        color: Colors.white.withOpacity(0.3),
        size: 24,
      ),
    );
  }
}
