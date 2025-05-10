import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A customizable scatter plot widget for Flutter
class ScatterPlot extends StatelessWidget {
  /// Data points to plot (x, y coordinates)
  final List<Point> dataPoints;

  /// Title of the chart
  final String title;

  /// Label for X axis
  final String xAxisLabel;

  /// Label for Y axis
  final String yAxisLabel;

  /// Width of the chart
  final double width;

  /// Height of the chart
  final double height;

  /// Background color of the chart
  final Color backgroundColor;

  /// Grid color
  final Color gridColor;

  /// Axis color
  final Color axisColor;

  /// Text color for labels and title
  final Color textColor;

  /// Whether to show grid lines
  final bool showGrid;

  /// Whether to show axis labels
  final bool showLabels;

  /// Whether to animate the chart when first shown
  final bool animate;

  /// Duration of the animation
  final Duration animationDuration;

  const ScatterPlot({
    Key? key,
    required this.dataPoints,
    this.title = 'Scatter Plot',
    this.xAxisLabel = 'X Axis',
    this.yAxisLabel = 'Y Axis',
    this.width = double.infinity,
    this.height = 300,
    this.backgroundColor = Colors.white,
    this.gridColor = const Color(0xFFEEEEEE),
    this.axisColor = Colors.black87,
    this.textColor = Colors.black87,
    this.showGrid = true,
    this.showLabels = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16.0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          // Chart area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return animate
                    ? AnimatedScatterPlotPainter(
                        dataPoints: dataPoints,
                        xAxisLabel: xAxisLabel,
                        yAxisLabel: yAxisLabel,
                        gridColor: gridColor,
                        axisColor: axisColor,
                        textColor: textColor,
                        showGrid: showGrid,
                        showLabels: showLabels,
                        animationDuration: animationDuration,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      )
                    : CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: ScatterPlotPainter(
                          dataPoints: dataPoints,
                          xAxisLabel: xAxisLabel,
                          yAxisLabel: yAxisLabel,
                          gridColor: gridColor,
                          axisColor: axisColor,
                          textColor: textColor,
                          showGrid: showGrid,
                          showLabels: showLabels,
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A data point for the scatter plot
class Point {
  /// X coordinate value
  final double x;

  /// Y coordinate value
  final double y;

  /// Color of the point
  final Color color;

  /// Size of the point
  final double size;

  /// Shape of the point
  final PointShape shape;

  const Point({
    required this.x,
    required this.y,
    this.color = Colors.blue,
    this.size = 8.0,
    this.shape = PointShape.circle,
  });
}

/// Available shapes for data points
enum PointShape {
  circle,
  square,
  triangle,
  diamond,
  cross,
}

/// Painter for the scatter plot
class ScatterPlotPainter extends CustomPainter {
  final List<Point> dataPoints;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color gridColor;
  final Color axisColor;
  final Color textColor;
  final bool showGrid;
  final bool showLabels;

  // Padding values
  final double paddingLeft = 60;
  final double paddingRight = 20;
  final double paddingTop = 20;
  final double paddingBottom = 40;

  ScatterPlotPainter({
    required this.dataPoints,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.gridColor,
    required this.axisColor,
    required this.textColor,
    required this.showGrid,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Find min and max values
    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (var point in dataPoints) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    // Add padding to min/max values
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.05;
    maxX += xRange * 0.05;
    minY -= yRange * 0.05;
    maxY += yRange * 0.05;

    // Available space for plotting
    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    // Scale factors
    final xScale = chartWidth / (maxX - minX);
    final yScale = chartHeight / (maxY - minY);

    // Function to convert data coordinates to canvas coordinates
    double xToCanvas(double x) => paddingLeft + (x - minX) * xScale;
    double yToCanvas(double y) =>
        size.height - paddingBottom - (y - minY) * yScale;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw grid if enabled
    if (showGrid) {
      paint.color = gridColor;

      // Vertical grid lines
      final xStep = calculateStep((maxX - minX) / 5);
      for (double x = (minX / xStep).ceil() * xStep; x <= maxX; x += xStep) {
        final xPos = xToCanvas(x);
        canvas.drawLine(
          Offset(xPos, size.height - paddingBottom),
          Offset(xPos, paddingTop),
          paint,
        );
      }

      // Horizontal grid lines
      final yStep = calculateStep((maxY - minY) / 5);
      for (double y = (minY / yStep).ceil() * yStep; y <= maxY; y += yStep) {
        final yPos = yToCanvas(y);
        canvas.drawLine(
          Offset(paddingLeft, yPos),
          Offset(size.width - paddingRight, yPos),
          paint,
        );
      }
    }

    // Draw axes
    paint.color = axisColor;

    // X axis
    canvas.drawLine(
      Offset(paddingLeft, size.height - paddingBottom),
      Offset(size.width - paddingRight, size.height - paddingBottom),
      paint,
    );

    // Y axis
    canvas.drawLine(
      Offset(paddingLeft, size.height - paddingBottom),
      Offset(paddingLeft, paddingTop),
      paint,
    );

    // Draw labels if enabled
    if (showLabels) {
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      // X axis ticks and labels
      final xStep = calculateStep((maxX - minX) / 5);
      for (double x = (minX / xStep).ceil() * xStep; x <= maxX; x += xStep) {
        final xPos = xToCanvas(x);

        // Draw tick
        canvas.drawLine(
          Offset(xPos, size.height - paddingBottom),
          Offset(xPos, size.height - paddingBottom + 5),
          paint,
        );

        // Draw label
        textPainter.text = TextSpan(
          text: x.toStringAsFixed(1),
          style: TextStyle(color: textColor, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(xPos - textPainter.width / 2, size.height - paddingBottom + 8),
        );
      }

      // Y axis ticks and labels
      final yStep = calculateStep((maxY - minY) / 5);
      for (double y = (minY / yStep).ceil() * yStep; y <= maxY; y += yStep) {
        final yPos = yToCanvas(y);

        // Draw tick
        canvas.drawLine(
          Offset(paddingLeft, yPos),
          Offset(paddingLeft - 5, yPos),
          paint,
        );

        // Draw label
        textPainter.text = TextSpan(
          text: y.toStringAsFixed(1),
          style: TextStyle(color: textColor, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(paddingLeft - textPainter.width - 8,
              yPos - textPainter.height / 2),
        );
      }

      // X axis label
      textPainter.text = TextSpan(
        text: xAxisLabel,
        style: TextStyle(color: textColor, fontSize: 12),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height - textPainter.height,
        ),
      );

      // Y axis label
      textPainter.text = TextSpan(
        text: yAxisLabel,
        style: TextStyle(color: textColor, fontSize: 12),
      );
      textPainter.layout();

      // Rotate canvas to draw vertical text
      canvas.save();
      canvas.translate(10, size.height / 2);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Draw data points
    for (var point in dataPoints) {
      final pointPaint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;

      final x = xToCanvas(point.x);
      final y = yToCanvas(point.y);

      // Draw based on shape
      switch (point.shape) {
        case PointShape.circle:
          canvas.drawCircle(Offset(x, y), point.size, pointPaint);
          break;
        case PointShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(x, y),
              width: point.size * 2,
              height: point.size * 2,
            ),
            pointPaint,
          );
          break;
        case PointShape.triangle:
          final path = Path();
          path.moveTo(x, y - point.size);
          path.lineTo(x + point.size, y + point.size);
          path.lineTo(x - point.size, y + point.size);
          path.close();
          canvas.drawPath(path, pointPaint);
          break;
        case PointShape.diamond:
          final path = Path();
          path.moveTo(x, y - point.size);
          path.lineTo(x + point.size, y);
          path.lineTo(x, y + point.size);
          path.lineTo(x - point.size, y);
          path.close();
          canvas.drawPath(path, pointPaint);
          break;
        case PointShape.cross:
          final strokePaint = Paint()
            ..color = point.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = point.size / 2;

          canvas.drawLine(
            Offset(x - point.size, y - point.size),
            Offset(x + point.size, y + point.size),
            strokePaint,
          );
          canvas.drawLine(
            Offset(x + point.size, y - point.size),
            Offset(x - point.size, y + point.size),
            strokePaint,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  // Calculate a nice step size for axis ticks
  double calculateStep(double rawStep) {
    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor());
    final normalized = rawStep / magnitude;

    if (normalized < 2) return 2 * (magnitude as double);
    if (normalized < 5) return 5 * (magnitude as double);
    return 10 * (magnitude as double);
  }
}

/// Animated version of the scatter plot
class AnimatedScatterPlotPainter extends StatefulWidget {
  final List<Point> dataPoints;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color gridColor;
  final Color axisColor;
  final Color textColor;
  final bool showGrid;
  final bool showLabels;
  final Duration animationDuration;
  final double width;
  final double height;

  const AnimatedScatterPlotPainter({
    Key? key,
    required this.dataPoints,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.gridColor,
    required this.axisColor,
    required this.textColor,
    required this.showGrid,
    required this.showLabels,
    required this.animationDuration,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _AnimatedScatterPlotPainterState createState() =>
      _AnimatedScatterPlotPainterState();
}

class _AnimatedScatterPlotPainterState extends State<AnimatedScatterPlotPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _AnimatingScatterPlotPainter(
            dataPoints: widget.dataPoints,
            xAxisLabel: widget.xAxisLabel,
            yAxisLabel: widget.yAxisLabel,
            gridColor: widget.gridColor,
            axisColor: widget.axisColor,
            textColor: widget.textColor,
            showGrid: widget.showGrid,
            showLabels: widget.showLabels,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class _AnimatingScatterPlotPainter extends CustomPainter {
  final List<Point> dataPoints;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color gridColor;
  final Color axisColor;
  final Color textColor;
  final bool showGrid;
  final bool showLabels;
  final double progress;

  _AnimatingScatterPlotPainter({
    required this.dataPoints,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.gridColor,
    required this.axisColor,
    required this.textColor,
    required this.showGrid,
    required this.showLabels,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final painter = ScatterPlotPainter(
      dataPoints: dataPoints,
      xAxisLabel: xAxisLabel,
      yAxisLabel: yAxisLabel,
      gridColor: gridColor,
      axisColor: axisColor,
      textColor: textColor,
      showGrid: showGrid,
      showLabels: showLabels,
    );

    // Draw the axes and grid first
    painter.paint(canvas, size);

    // Then animate the points appearing
    for (int i = 0; i < (dataPoints.length * progress).ceil(); i++) {
      if (i >= dataPoints.length) break;

      final point = dataPoints[i];
      final pointScale = i < dataPoints.length * progress - 1
          ? 1.0
          : (dataPoints.length * progress) % 1.0;

      // Find min and max values (copied from ScatterPlotPainter)
      double minX = double.infinity;
      double maxX = -double.infinity;
      double minY = double.infinity;
      double maxY = -double.infinity;

      for (var p in dataPoints) {
        minX = math.min(minX, p.x);
        maxX = math.max(maxX, p.x);
        minY = math.min(minY, p.y);
        maxY = math.max(maxY, p.y);
      }

      // Add padding to min/max values
      final xRange = maxX - minX;
      final yRange = maxY - minY;
      minX -= xRange * 0.05;
      maxX += xRange * 0.05;
      minY -= yRange * 0.05;
      maxY += yRange * 0.05;

      // Available space for plotting
      final chartWidth =
          size.width - painter.paddingLeft - painter.paddingRight;
      final chartHeight =
          size.height - painter.paddingTop - painter.paddingBottom;

      // Scale factors
      final xScale = chartWidth / (maxX - minX);
      final yScale = chartHeight / (maxY - minY);

      // Function to convert data coordinates to canvas coordinates
      double xToCanvas(double x) => painter.paddingLeft + (x - minX) * xScale;
      double yToCanvas(double y) =>
          size.height - painter.paddingBottom - (y - minY) * yScale;

      final pointPaint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;

      final x = xToCanvas(point.x);
      final y = yToCanvas(point.y);
      final scaledSize = point.size * pointScale;

      // Draw based on shape
      switch (point.shape) {
        case PointShape.circle:
          canvas.drawCircle(Offset(x, y), scaledSize, pointPaint);
          break;
        case PointShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(x, y),
              width: scaledSize * 2,
              height: scaledSize * 2,
            ),
            pointPaint,
          );
          break;
        case PointShape.triangle:
          final path = Path();
          path.moveTo(x, y - scaledSize);
          path.lineTo(x + scaledSize, y + scaledSize);
          path.lineTo(x - scaledSize, y + scaledSize);
          path.close();
          canvas.drawPath(path, pointPaint);
          break;
        case PointShape.diamond:
          final path = Path();
          path.moveTo(x, y - scaledSize);
          path.lineTo(x + scaledSize, y);
          path.lineTo(x, y + scaledSize);
          path.lineTo(x - scaledSize, y);
          path.close();
          canvas.drawPath(path, pointPaint);
          break;
        case PointShape.cross:
          final strokePaint = Paint()
            ..color = point.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = scaledSize / 2;

          canvas.drawLine(
            Offset(x - scaledSize, y - scaledSize),
            Offset(x + scaledSize, y + scaledSize),
            strokePaint,
          );
          canvas.drawLine(
            Offset(x + scaledSize, y - scaledSize),
            Offset(x - scaledSize, y + scaledSize),
            strokePaint,
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Example usage:
class ScatterPlotExample extends StatelessWidget {
  const ScatterPlotExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate some random data points
    final random = math.Random();
    final dataPoints = List.generate(
      30,
      (index) => Point(
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
        color: Color.fromARGB(
          255,
          random.nextInt(255),
          random.nextInt(255),
          random.nextInt(255),
        ),
        size: random.nextDouble() * 5 + 3,
        shape: PointShape.values[random.nextInt(PointShape.values.length)],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scatter Plot Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScatterPlot(
          dataPoints: dataPoints,
          title: 'Random Data Scatter Plot',
          xAxisLabel: 'X Values',
          yAxisLabel: 'Y Values',
          showGrid: true,
          showLabels: true,
          animate: true,
        ),
      ),
    );
  }
}
