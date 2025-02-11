import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<List<int>> boundingBoxes;
  final double cameraAspectRatio;
  final Size previewSize;

  BoundingBoxPainter({
    required this.boundingBoxes,
    required this.cameraAspectRatio,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;

    for (var box in boundingBoxes) {
      final rect = Rect.fromLTRB(
        box[0].toDouble() * scaleX,
        box[1].toDouble() * scaleY,
        box[2].toDouble() * scaleX,
        box[3].toDouble() * scaleY,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
