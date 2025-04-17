import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';

class ElevatedCard extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final double? width;
  final double? height;
  final Color? titleColor;
  final Color? descriptionColor;
  final Widget? child;

  const ElevatedCard({
    super.key,
    required this.title,
    required this.description,
    required this.backgroundColor,
    this.width,
    this.height,
    this.titleColor,
    this.descriptionColor,
    this.child,
  });

  /// Factory constructor for creating square-shaped cards
  factory ElevatedCard.square({
    required String title,
    required String description,
    required Color backgroundColor,
    required double size,
    Color? titleColor,
    Color? descriptionColor,
    Widget? child,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: size,
      height: size,
      titleColor: titleColor,
      descriptionColor: descriptionColor,
      child: child,
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
    Widget? child,
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
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
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

          // ✅ Center the child widget if provided
          if (child != null) Center(child: child!),
        ],
      ),
    );
  }
}
