import 'package:flutter/material.dart';
import '../theme/text_styles.dart';
import '../theme/app_colors.dart';
import '../utils/size_config.dart';
import '../widgets/navigation_sidebar.dart';
import '../widgets/monitoring_pages/elevated_info_card.dart';

class HealthAnalysisPage extends StatelessWidget {
  const HealthAnalysisPage({super.key});

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
                    'Health Analysis',
                    style: TextStyles.mainHeading.copyWith(
                      color: AppColors.sidebarGradientStart,
                    ),
                  ),
                ),
                // Health cards grid (dynamic number of boxes in 2 rows)
                SizedBox(
                  height: SizeConfig.proportionateScreenHeight(500),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InfoCardsGrid(
                      n: 6, // Example: Display 6 cards
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

class InfoCardsGrid extends StatelessWidget {
  final int n; // Number of cards to display

  const InfoCardsGrid({super.key, required this.n});

  @override
  Widget build(BuildContext context) {
    // Calculate the number of cards per row (ensuring 2 rows max)
    int cardsPerRow = (n / 2).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Divide available height equally between 2 rows
        double rowHeight = constraints.maxHeight / 2;

        return Column(
          children: List.generate(2, (rowIndex) {
            // Calculate the cards for the current row
            int startIndex = rowIndex * cardsPerRow;
            int endIndex = (startIndex + cardsPerRow).clamp(0, n);

            // If there are no cards left for this row, return an empty container
            if (startIndex >= n) {
              return SizedBox(height: rowHeight);
            }

            return SizedBox(
              height: rowHeight,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center cards in the row
                children: List.generate(endIndex - startIndex, (index) {
                  int cardNumber = startIndex + index + 1;
                  return Flexible(
                    fit: FlexFit.tight, // Adjust card size proportionally
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 4.0,
                          right: 4.0), // Reduced padding
                      child: ElevatedInfoCard(
                        title: 'Card $cardNumber',
                        image:
                            'assets/placeholder_icon.png', // Placeholder image
                        number: cardNumber, // Display card number
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}
