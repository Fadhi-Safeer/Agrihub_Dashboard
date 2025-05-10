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
                    style: TextStyles.elevatedCardTitle,
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
                        SizedBox(width: 20),
                        Expanded(
                          child: ScatterPlot(
                            dataPoints: [
                              Point(
                                  x: 10,
                                  y: 200,
                                  color: Colors.blue,
                                  shape: PointShape.circle),
                              Point(
                                  x: 150,
                                  y: 35,
                                  color: Colors.red,
                                  size: 10,
                                  shape: PointShape.circle),
                              // ... (rest of your points)
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
                            animationDuration: Duration(milliseconds: 800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Growth Summary Text
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
}
