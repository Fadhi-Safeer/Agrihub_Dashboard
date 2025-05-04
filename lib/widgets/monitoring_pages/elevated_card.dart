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
  final bool showTopBar;
  final List<Color> topBarGradientColors;

  const ElevatedCard({
    super.key,
    this.title = '',
    this.description = '',
    this.backgroundColor = Colors.white,
    this.width,
    this.height,
    this.titleColor,
    this.descriptionColor,
    this.child,
    this.showTopBar = false,
    this.topBarGradientColors = const [
      Color(0xFFFF5E9C),
      Color(0xFFFFB157)
    ], // Default gradient
  });

  factory ElevatedCard.square({
    required String title,
    required String description,
    Color backgroundColor = Colors.white,
    required double size,
    Color? titleColor,
    Color? descriptionColor,
    Widget? child,
    bool showTopBar = false,
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
      showTopBar: showTopBar,
    );
  }

  factory ElevatedCard.elevated({
    String title = '', // Default to empty string if no title is provided
    String description = '',
    Color backgroundColor = Colors.white,
    required double width,
    required double heightMultiplier,
    Color? titleColor,
    Color? descriptionColor,
    Widget? child,
    bool showTopBar = false,
  }) {
    return ElevatedCard(
      title: title,
      description: description,
      backgroundColor: backgroundColor,
      width: width,
      height: width * heightMultiplier,
      titleColor: titleColor,
      descriptionColor: descriptionColor,
      child: child,
      showTopBar: showTopBar,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with gradient if enabled
          if (showTopBar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      topBarGradientColors, // Use the provided gradient colors
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyles.elevatedCardTitle.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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

          // Optional child below
          if (child != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child!,
              ),
            ),
        ],
      ),
    );
  }
}
