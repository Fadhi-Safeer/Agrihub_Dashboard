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
    final scaleX = size.width / previewSize.width;
    final scaleY = size.height / previewSize.height;

    for (var box in boundingBoxes) {
      final x1 = (box["x1"] ?? 0).toDouble() * scaleX;
      final y1 = (box["y1"] ?? 0).toDouble() * scaleY;
      final x2 = (box["x2"] ?? 0).toDouble() * scaleX;
      final y2 = (box["y2"] ?? 0).toDouble() * scaleY;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);

      // Determine box color by classification label (growth stage)
      final label = (box["growth"] ?? "").toString().toLowerCase();
      Color boxColor = AppColors.neonGreen; // Default fallback

      if (label.contains("early")) {
        boxColor = Colors.lightGreenAccent;
      } else if (label.contains("leafy")) {
        boxColor = Colors.green[800]!;
      } else if (label.contains("harvest")) {
        boxColor = Colors.orange;
      }

      final paint = Paint()
        ..color = boxColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw rectangle
      canvas.drawRect(rect, paint);

      // Draw label text above the box
      if (label.isNotEmpty) {
        final textSpan = TextSpan(
          text: label.replaceAll("_", " "), // Optional formatting
          style: TextStyle(
            color: boxColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final offset =
            Offset(x1, y1 - textPainter.height - 2); // Slightly above box
        textPainter.paint(canvas, offset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
