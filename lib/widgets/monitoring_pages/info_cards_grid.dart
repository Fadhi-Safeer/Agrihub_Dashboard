import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'elevated_card.dart';

class InfoCardsGrid extends StatelessWidget {
  final int n; // Number of cards to display
  final int rows; // Number of rows to display (1 or 2, defaults to 2)

  const InfoCardsGrid({
    super.key,
    required this.n,
    this.rows = 2, // Default number of rows
  });

  @override
  Widget build(BuildContext context) {
    // Ensure rows is either 1 or 2; otherwise, default to 2
    final int validRows = (rows == 1 || rows == 2) ? rows : 2;

    // Calculate the number of cards per row based on validRows
    int cardsPerRow = (n / validRows).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Dynamically calculate row height based on available height and spacing
        double availableHeight = constraints.maxHeight;
        double rowHeight = (availableHeight - ((validRows - 1) * 8.0)) /
            validRows; // Subtract inter-row spacing

        return Column(
          children: List.generate(validRows, (rowIndex) {
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
                          top: 8.0,
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0), // Adjusted padding
                      child: ElevatedCard(
                        title: 'Crop - $cardNumber',
                        description: ' $cardNumber',
                        backgroundColor: AppColors.cardBackground,
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
