import 'dart:math';
import 'package:flutter/material.dart';

class RadarChartData {
  final String label;
  final double value;

  RadarChartData({required this.label, required this.value});
}

class RadarChart extends StatelessWidget {
  /// The data points to display on the radar chart
  final List<RadarChartData> data;

  /// The color of the filled polygon
  final Color fillColor;

  /// The color of the radar chart border
  final Color borderColor;

  /// The color of the grid lines
  final Color gridColor;

  /// The color of the labels
  final Color labelColor;

  /// The number of concentric circles to draw
  final int divisions;

  /// The size of the labels
  final double labelFontSize;

  /// The stroke width of the border
  final double borderWidth;

  /// The stroke width of the grid lines
  final double gridWidth;

  /// Whether to show the labels
  final bool showLabels;

  /// Whether to animate the chart
  final bool animate;

  /// Animation duration in milliseconds
  final int animationDuration;

  const RadarChart({
    Key? key,
    required this.data,
    this.fillColor = const Color(0x40FF8C00),
    this.borderColor = const Color(0xFFFF8C00),
    this.gridColor = const Color(0x30000000),
    this.labelColor = const Color(0xFF333333),
    this.divisions = 5,
    this.labelFontSize = 12.0,
    this.borderWidth = 2.0,
    this.gridWidth = 1.0,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = 500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);

        return Container(
          width: size,
          height: size,
          child: animate
              ? TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: animationDuration),
                  builder: (context, double value, child) {
                    return CustomPaint(
                      size: Size(size, size),
                      painter: _RadarChartPainter(
                        data: data,
                        fillColor: fillColor,
                        borderColor: borderColor,
                        gridColor: gridColor,
                        labelColor: labelColor,
                        divisions: divisions,
                        labelFontSize: labelFontSize,
                        borderWidth: borderWidth,
                        gridWidth: gridWidth,
                        showLabels: showLabels,
                        animationValue: value,
                      ),
                    );
                  },
                )
              : CustomPaint(
                  size: Size(size, size),
                  painter: _RadarChartPainter(
                    data: data,
                    fillColor: fillColor,
                    borderColor: borderColor,
                    gridColor: gridColor,
                    labelColor: labelColor,
                    divisions: divisions,
                    labelFontSize: labelFontSize,
                    borderWidth: borderWidth,
                    gridWidth: gridWidth,
                    showLabels: showLabels,
                    animationValue: 1.0,
                  ),
                ),
        );
      },
    );
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<RadarChartData> data;
  final Color fillColor;
  final Color borderColor;
  final Color gridColor;
  final Color labelColor;
  final int divisions;
  final double labelFontSize;
  final double borderWidth;
  final double gridWidth;
  final bool showLabels;
  final double animationValue;

  _RadarChartPainter({
    required this.data,
    required this.fillColor,
    required this.borderColor,
    required this.gridColor,
    required this.labelColor,
    required this.divisions,
    required this.labelFontSize,
    required this.borderWidth,
    required this.gridWidth,
    required this.showLabels,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        min(size.width, size.height) / 2 * 0.8; // Leave 20% margin for labels

    // Draw the grid lines
    _drawGridLines(canvas, center, radius);

    // Draw the data polygon
    _drawDataPolygon(canvas, center, radius);

    // Draw the data points
    _drawDataPoints(canvas, center, radius);

    // Draw the labels
    if (showLabels) {
      _drawLabels(canvas, center, radius);
    }
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = gridWidth
      ..style = PaintingStyle.stroke;

    // Draw the rings
    for (int i = 1; i <= divisions; i++) {
      final ringRadius = radius * i / divisions;
      canvas.drawCircle(center, ringRadius, gridPaint);
    }

    // Draw the spokes
    final spokePaint = Paint()
      ..color = gridColor
      ..strokeWidth = gridWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < data.length; i++) {
      final angle = 2 * pi * i / data.length - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), spokePaint);
    }
  }

  void _drawDataPolygon(Canvas canvas, Offset center, double radius) {
    if (data.isEmpty) return;

    final path = Path();
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final value = data[i].value * animationValue;
      final angle = 2 * pi * i / data.length - pi / 2;
      final x = center.dx + radius * value * cos(angle);
      final y = center.dy + radius * value * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius) {
    final pointPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth * 1.5
      ..style = PaintingStyle.stroke;

    final pointFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final value = data[i].value * animationValue;
      final angle = 2 * pi * i / data.length - pi / 2;
      final x = center.dx + radius * value * cos(angle);
      final y = center.dy + radius * value * sin(angle);

      canvas.drawCircle(Offset(x, y), borderWidth * 2, pointFillPaint);
      canvas.drawCircle(Offset(x, y), borderWidth * 2, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    final labelRadius = radius + labelFontSize;

    for (int i = 0; i < data.length; i++) {
      final angle = 2 * pi * i / data.length - pi / 2;
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: TextStyle(
            color: labelColor,
            fontSize: labelFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Adjust the position to center the text around the point
      double textX = x - textPainter.width / 2;
      double textY = y - textPainter.height / 2;

      // Move text a bit more outward depending on angle
      if (angle < -pi * 0.9 || angle > pi * 0.9) {
        textX -= textPainter.width * 0.2;
      } else if (angle > -pi * 0.1 && angle < pi * 0.1) {
        textX += textPainter.width * 0.2;
      }

      if (angle > 0) {
        textY += textPainter.height * 0.2;
      } else {
        textY -= textPainter.height * 0.2;
      }

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.data != data ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}
