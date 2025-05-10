import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../graphs/custom_pie_chart.dart';
import '../graphs/scatter_plot.dart';

class InfoBoxOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const InfoBoxOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth Summary',
                    style: TextStyles.elevatedCardTitle.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: CustomPieChart(
                            values: [40, 30, 20, 10],
                            colors: [
                              Colors.blue,
                              Colors.green,
                              Colors.orange,
                              Colors.red,
                            ],
                            titles: ['Apples', 'Bananas', 'Cherries', 'Dates'],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ScatterPlot(
                            dataPoints: [
                              Point(
                                  x: 10,
                                  y: 300,
                                  color: Colors.blue,
                                  shape: PointShape.circle),
                              Point(
                                  x: 150,
                                  y: 35,
                                  color: Colors.red,
                                  size: 10,
                                  shape: PointShape.circle),
                              Point(
                                  x: 190,
                                  y: 45,
                                  color: Colors.deepOrange,
                                  shape: PointShape.circle),
                            ],
                            title: 'Custom Scatter Plot',
                            xAxisLabel: 'Days',
                            yAxisLabel: 'Value',
                            backgroundColor: AppColors.cardBackground,
                            gridColor: Colors.grey.shade200,
                            axisColor: Colors.black87,
                            textColor: Colors.black87,
                            showGrid: true,
                            showLabels: true,
                            animate: true,
                            animationDuration:
                                const Duration(milliseconds: 800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Side by side stats cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: Icons.eco,
                        value: '345',
                        label: 'Total Plants',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        icon: Icons.trending_up,
                        value: '78%',
                        label: 'Avg Growth',
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        icon: Icons.calendar_today,
                        value: '12',
                        label: 'Harvest Days',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Progress Bar Section
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
