import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';

class ElevatedCardWithImageGrid extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final double? width;
  final double? height;
  final Color? titleColor;
  final List<Widget> images;
  final int imagesPerRow;
  final double imageSpacing;

  const ElevatedCardWithImageGrid({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.images,
    this.width,
    this.height,
    this.titleColor,
    this.imagesPerRow = 2,
    this.imageSpacing = 8.0,
  });

  /// Factory constructor for square-shaped cards with image grid
  factory ElevatedCardWithImageGrid.square({
    required String title,
    required Color backgroundColor,
    required List<Widget> images,
    required double size,
    Color? titleColor,
    int imagesPerRow = 2,
    double imageSpacing = 8.0,
  }) {
    return ElevatedCardWithImageGrid(
      title: title,
      backgroundColor: backgroundColor,
      images: images,
      width: size,
      height: size,
      titleColor: titleColor,
      imagesPerRow: imagesPerRow,
      imageSpacing: imageSpacing,
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
          // Title at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyles.elevatedCardTitle.copyWith(
                color: titleColor ?? TextStyles.elevatedCardTitle.color,
              ),
            ),
          ),

          // Image grid below the title
          Expanded(
            child: _buildImageGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    // Calculate number of rows needed (max 2 as requested)
    final int rowCount = (images.length / imagesPerRow).ceil().clamp(1, 2);
    final int itemsInLastRow = images.length % imagesPerRow;

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        final isLastRow = rowIndex == rowCount - 1;
        final itemsInThisRow =
            isLastRow && itemsInLastRow != 0 ? itemsInLastRow : imagesPerRow;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: imageSpacing,
              right: imageSpacing,
              bottom: isLastRow ? imageSpacing : 0,
            ),
            child: Row(
              children: List.generate(itemsInThisRow, (itemIndex) {
                final imageIndex = rowIndex * imagesPerRow + itemIndex;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: imageSpacing,
                      left: itemIndex > 0 ? imageSpacing : 0,
                    ),
                    child: images[imageIndex],
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}
