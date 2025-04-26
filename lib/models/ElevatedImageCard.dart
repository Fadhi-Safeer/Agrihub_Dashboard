import 'dart:ui';

class ImageCard {
  final String title;
  final String description;
  final Color color;
  final int slotCount;
  final List<String?> slotImages;

  ImageCard({
    required this.title,
    this.description = "", // Default count
    this.color = const Color(0xFFCCCCCC), // Default color (light gray)
    this.slotCount = 1, // Default slot count
    this.slotImages = const [], // Default empty list of images
  });
}
