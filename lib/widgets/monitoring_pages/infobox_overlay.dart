import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../graphs/custom_pie_chart.dart';

class GrowthSummaryOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const GrowthSummaryOverlay({super.key, required this.onClose});

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

                  // Auto-adjusting Pie Chart Section
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: CustomPieChart(
                        values: [40, 30, 20, 10],
                        colors: [
                          Colors.blue,
                          Colors.green,
                          Colors.orange,
                          Colors.red
                        ],
                        titles: ['Apples', 'Bananas', 'Cherries', 'Dates'],
                      ),
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
