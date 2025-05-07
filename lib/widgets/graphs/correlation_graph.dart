import 'package:flutter/material.dart';
import 'dart:math' as math;

class SeverityData {
  final String label;
  final double value;
  final Color color;

  SeverityData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class SeverityLevelBarChart extends StatelessWidget {
  final List<SeverityData> data;
  final String xAxisTitle;
  final String yAxisTitle;
  final double? barWidth;
  final double? barSpacing;
  final double? maxValue;
  final Color backgroundColor;
  final Color textColor;
  final Color gridColor;
  final EdgeInsets padding;

  const SeverityLevelBarChart({
    Key? key,
    required this.data,
    this.xAxisTitle = 'Category',
    this.yAxisTitle = 'Severity Level',
    this.barWidth = 30.0,
    this.barSpacing = 15.0,
    this.maxValue,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.gridColor = Colors.black12,
    this.padding = const EdgeInsets.fromLTRB(40, 20, 20, 40),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: backgroundColor,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _SeverityLevelBarChartPainter(
              data: data,
              xAxisTitle: xAxisTitle,
              yAxisTitle: yAxisTitle,
              barWidth: barWidth!,
              barSpacing: barSpacing!,
              maxValue: maxValue,
              textColor: textColor,
              gridColor: gridColor,
              padding: padding,
            ),
          ),
        );
      },
    );
  }
}

class _SeverityLevelBarChartPainter extends CustomPainter {
  final List<SeverityData> data;
  final String xAxisTitle;
  final String yAxisTitle;
  final double barWidth;
  final double barSpacing;
  final double? maxValue;
  final Color textColor;
  final Color gridColor;
  final EdgeInsets padding;

  _SeverityLevelBarChartPainter({
    required this.data,
    required this.xAxisTitle,
    required this.yAxisTitle,
    required this.barWidth,
    required this.barSpacing,
    this.maxValue,
    required this.textColor,
    required this.gridColor,
    required this.padding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - padding.left - padding.right;
    final chartHeight = size.height - padding.top - padding.bottom;
    final chartBottom = size.height - padding.bottom;
    final chartLeft = padding.left;

    // Calculate the maximum value for scaling
    final actualMaxValue =
        maxValue ?? data.fold(0.0, (max, item) => math.max(max!, item.value));

    // Draw grid lines and labels
    final horizontalLineCount = 5;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    for (int i = 0; i <= horizontalLineCount; i++) {
      final y = chartBottom - (i * chartHeight / horizontalLineCount);

      // Draw grid line
      final linePaint = Paint()
        ..color = gridColor
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartLeft + chartWidth, y),
        linePaint,
      );

      // Draw y-axis label
      final value = (i * actualMaxValue! / horizontalLineCount);
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(1),
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(chartLeft - textPainter.width - 5, y - textPainter.height / 2),
      );
    }

    // Draw y-axis title
    textPainter.text = TextSpan(
      text: yAxisTitle,
      style: TextStyle(
          color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();

    // Rotate and position the y-axis title
    canvas.save();
    canvas.translate(padding.left / 4, size.height / 2);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();

    // Draw the bars
    final barTotalWidth = barWidth + barSpacing;
    final adjustedBarWidth = chartWidth / data.length < barTotalWidth
        ? (chartWidth / data.length) - (barSpacing / 2)
        : barWidth;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final barHeight = (item.value / actualMaxValue!) * chartHeight;
      final x =
          chartLeft + i * (adjustedBarWidth + barSpacing) + barSpacing / 2;
      final y = chartBottom - barHeight;

      // Draw bar
      final barPaint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(x, y, adjustedBarWidth, barHeight),
        barPaint,
      );

      // Draw x-axis label
      textPainter.text = TextSpan(
        text: item.label,
        style: TextStyle(color: textColor, fontSize: 10),
      );
      textPainter.layout();

      // Rotate the text if needed based on available space
      final labelCenter = x + adjustedBarWidth / 2;
      if (textPainter.width > adjustedBarWidth + barSpacing) {
        canvas.save();
        canvas.translate(labelCenter, chartBottom + 5);
        canvas.rotate(math.pi / 4);
        textPainter.paint(canvas, Offset(0, 0));
        canvas.restore();
      } else {
        textPainter.paint(
          canvas,
          Offset(labelCenter - textPainter.width / 2, chartBottom + 5),
        );
      }
    }

    // Draw x-axis title
    textPainter.text = TextSpan(
      text: xAxisTitle,
      style: TextStyle(
          color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height - padding.bottom / 3,
      ),
    );

    // Draw axes
    final axesPaint = Paint()
      ..color = textColor
      ..strokeWidth = 1.0;

    // Y-axis
    canvas.drawLine(
      Offset(chartLeft, padding.top),
      Offset(chartLeft, chartBottom),
      axesPaint,
    );

    // X-axis
    canvas.drawLine(
      Offset(chartLeft, chartBottom),
      Offset(chartLeft + chartWidth, chartBottom),
      axesPaint,
    );
  }

  @override
  bool shouldRepaint(_SeverityLevelBarChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.barSpacing != barSpacing ||
        oldDelegate.xAxisTitle != xAxisTitle ||
        oldDelegate.yAxisTitle != yAxisTitle;
  }
}
