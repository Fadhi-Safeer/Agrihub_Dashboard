import 'package:agrihub_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> boundingBoxes;
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
      ..color = AppColors.neonGreen
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;

    for (var box in boundingBoxes) {
      final x1 = box["x1"].toDouble() * scaleX;
      final y1 = box["y1"].toDouble() * scaleY;
      final x2 = box["x2"].toDouble() * scaleX;
      final y2 = box["y2"].toDouble() * scaleY;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
