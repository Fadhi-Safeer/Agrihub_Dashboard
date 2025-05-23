import 'package:flutter/material.dart';

import '../../theme/text_styles.dart';

class BulletPointsCard extends StatelessWidget {
  final String title;
  final List<String> bulletPoints;
  final List<Color> bulletColors;

  const BulletPointsCard({
    super.key,
    required this.title,
    required this.bulletPoints,
    required this.bulletColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyles.elevatedCardDescription,
            ),
            const SizedBox(height: 8.0),
            ...bulletPoints.asMap().entries.map((entry) {
              int index = entry.key;
              String point = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.only(right: 8.0, top: 4.0),
                      decoration: BoxDecoration(
                        color: bulletColors[index % bulletColors.length],
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyles.rightPanelHeadingText.copyWith(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
