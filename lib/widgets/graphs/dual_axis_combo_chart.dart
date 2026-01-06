import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DualAxisPoint {
  final DateTime time;
  final double leftValue; // temp or humidity
  final double rightValue; // growth
  DualAxisPoint(this.time, this.leftValue, this.rightValue);
}

class DualAxisComboChart extends StatelessWidget {
  final String title;
  final String leftName; // e.g. "Temperature (°C)" or "Humidity (%)"
  final String rightName; // e.g. "Growth"
  final List<DualAxisPoint> points;

  /// If your growth is 0.0–1.0, set growthIsRatio=true (it will show 0–100% on axis)
  final bool growthIsRatio;

  const DualAxisComboChart({
    super.key,
    required this.title,
    required this.leftName,
    required this.rightName,
    required this.points,
    this.growthIsRatio = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text("No data"));
    }

    // Map growth ratio -> %
    final mapped = points
        .map((p) => _MappedPoint(
              p.time,
              p.leftValue,
              growthIsRatio ? (p.rightValue * 100.0) : p.rightValue,
            ))
        .toList();

    final leftMin = mapped.map((e) => e.left).reduce((a, b) => a < b ? a : b);
    final leftMax = mapped.map((e) => e.left).reduce((a, b) => a > b ? a : b);

    final rightMin = mapped.map((e) => e.right).reduce((a, b) => a < b ? a : b);
    final rightMax = mapped.map((e) => e.right).reduce((a, b) => a > b ? a : b);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      title: ChartTitle(text: title, textStyle: const TextStyle(fontSize: 12)),
      legend: const Legend(isVisible: true, position: LegendPosition.top),
      tooltipBehavior: TooltipBehavior(enable: true, shared: true),

      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
      ),

      // LEFT axis (Temp/Humidity)
      primaryYAxis: NumericAxis(
        minimum: _padMin(leftMin),
        maximum: _padMax(leftMax),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        title: AxisTitle(text: leftName),
      ),

      // RIGHT axis (Growth)
      axes: <ChartAxis>[
        NumericAxis(
          name: 'growthAxis',
          opposedPosition: true,
          minimum: _padMin(rightMin),
          maximum: _padMax(rightMax),
          majorGridLines: const MajorGridLines(width: 0),
          title: AxisTitle(text: rightName),
        )
      ],

      series: <CartesianSeries<_MappedPoint, DateTime>>[
        // Left axis line (Temp/Humidity)
        LineSeries<_MappedPoint, DateTime>(
          name: leftName,
          dataSource: mapped,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.left,
          width: 2,
          markerSettings: const MarkerSettings(isVisible: true),
        ),

        // Right axis column/line (Growth). I’ll use a line; change to ColumnSeries if you want.
        LineSeries<_MappedPoint, DateTime>(
          name: rightName,
          yAxisName: 'growthAxis',
          dataSource: mapped,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.right,
          width: 2,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  double _padMin(double v) =>
      (v - (v.abs() * 0.05)).isNaN ? 0 : (v - (v.abs() * 0.05));
  double _padMax(double v) =>
      (v + (v.abs() * 0.05)).isNaN ? 1 : (v + (v.abs() * 0.05));
}

class _MappedPoint {
  final DateTime time;
  final double left;
  final double right;
  _MappedPoint(this.time, this.left, this.right);
}
