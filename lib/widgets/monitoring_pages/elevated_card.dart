import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';

class ElevatedCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final double? width; // Optional width for square or elevated cards
  final double? height; // Optional height for elevated cards
  final Color? titleColor; // Optional color for the title
  final Color? descriptionColor; // Optional color for the description

  const ElevatedCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    this.width,
    this.height,
    this.titleColor, // Title color
    this.descriptionColor, // Description color
  });

  /// Factory constructor for creating square-shaped cards
  factory ElevatedCard.square({
    required String title,
    required String description,
    required Color backgroundColor,
    required double size,
    Color? titleColor,
    Color? descriptionColor,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
      titleColor: titleColor,
      descriptionColor: descriptionColor,
    );
  }

  /// Factory constructor for creating elevated cards with a height multiplier
  factory ElevatedCard.elevated({
    required String title,
    required String description,
    required Color backgroundColor,
    required double width,
    required double heightMultiplier,
    Color? titleColor,
    Color? descriptionColor,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: width,
      height: width * heightMultiplier, // Multiply width by height multiplier
      titleColor: titleColor,
      descriptionColor: descriptionColor,
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
          mainAxisAlignment:
              MainAxisAlignment.start, // Align content to the top
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align content to the left
          children: [
            Text(
              title,
              style: TextStyles.elevatedCardTitle.copyWith(
                color: titleColor ?? TextStyles.elevatedCardTitle.color,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyles.elevatedCardDescription.copyWith(
                color: descriptionColor ??
                    TextStyles.elevatedCardDescription.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
