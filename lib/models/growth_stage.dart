import 'dart:ui';

class GrowthStage {
  final String title;
  final String count;
  final Color color;
  final int slotCount;
  final List<String?> slotImages;

  GrowthStage({
    required this.title,
    required this.count,
    required this.color,
    required this.slotCount,
    required this.slotImages,
  });
}
