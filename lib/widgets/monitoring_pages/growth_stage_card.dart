import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/growth_stage.dart';

class GrowthCard extends StatelessWidget {
  final GrowthStage stage;

  const GrowthCard({super.key, required this.stage});

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
          // Title only (description removed)
          Text(
            stage.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12), // Reduced spacing

          // Slot Grid
          Expanded(
            child: Column(
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
                    itemCount: min(itemsPerRow, stage.slotCount - itemsPerRow),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                          fit: BoxFit.cover,
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
