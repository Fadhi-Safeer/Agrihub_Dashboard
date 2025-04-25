import 'dart:ui';

class GrowthStage {
  final String title;
  final String description;
  final Color color;
  final int slotCount;
  final List<String?> slotImages;

  GrowthStage({
    required this.title,
    this.description = '0', // Default count
    this.color = const Color(0xFFCCCCCC), // Default color (light gray)
    this.slotCount = 1, // Default slot count
    this.slotImages = const [], // Default empty list of images
  });
}
