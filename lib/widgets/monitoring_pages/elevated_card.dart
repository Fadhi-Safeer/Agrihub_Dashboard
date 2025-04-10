import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';

class ElevatedCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final double? width; // Optional width for square or elevated cards
  final double? height; // Optional height for elevated cards

  const ElevatedCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    this.width,
    this.height,
  });

  /// Factory constructor for creating square-shaped cards
  factory ElevatedCard.square({
    required String title,
    required String description,
    required Color backgroundColor,
    required double size,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
    );
  }

  /// Factory constructor for creating elevated cards with a height multiplier
  factory ElevatedCard.elevated({
    required String title,
    required String description,
    required Color backgroundColor,
    required double width,
    required double heightMultiplier,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: width,
      height: width * heightMultiplier, // Multiply width by height multiplier
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Width, if provided
      height: height, // Height, if provided
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
              style: TextStyles.rightPanelHeadingText.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
