import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/ImageCard.dart';
import '../../theme/text_styles.dart';

class ElevatedImageCard extends StatelessWidget {
  final ImageCard stage;

  const ElevatedImageCard({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final int itemsPerRow = (stage.slotCount / 2).ceil();

    return Container(
      decoration: BoxDecoration(
        color: stage.color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Title
          Text(
            stage.title,
            style: TextStyles.elevatedCardTitle,
          ),

          const SizedBox(height: 12), // Reduced spacing

          // Slot Grid
          Expanded(
            child: stage.slotCount == 1
                ? _buildSingleSlot() // Handle single slot case
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // First row of slots
                      Expanded(
                        child: _buildSlotRow(
                          startIndex: 0,
                          itemCount: itemsPerRow,
                        ),
                      ),
                      // Second row of slots
                      Expanded(
                        child: _buildSlotRow(
                          startIndex: itemsPerRow,
                          itemCount:
                              min(itemsPerRow, stage.slotCount - itemsPerRow),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(
              height: 12), // Add spacing between the grid and description

          // Description
          Text(
            stage.description, // Updated to use 'description'
            style: TextStyles.elevatedCardDescription,
            textAlign: TextAlign.center, // Center align the description
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSlot() {
    final String? imagePath =
        stage.slotImages.isNotEmpty ? stage.slotImages[0] : null;

    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imagePath != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // Ensures the image fits entirely
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildSlotRow({
    required int startIndex,
    required int itemCount,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(itemCount, (index) {
        final slotIndex = startIndex + index;
        final imagePath = slotIndex < stage.slotImages.length
            ? stage.slotImages[slotIndex]
            : null;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          fit:
                              BoxFit.contain, // Ensures the image fits entirely
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.crop_square,
        color: Colors.white.withOpacity(0.3),
        size: 24,
      ),
    );
  }
}
