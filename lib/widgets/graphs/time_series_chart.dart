import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TimeSeriesChart extends StatelessWidget {
  final List<TimeSeriesDataSet> dataSets;
  final bool showMarkers;
  final bool showArea;

  const TimeSeriesChart({
    super.key,
    required this.dataSets,
    this.showMarkers = true,
    this.showArea = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate min and max values from all data sets
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var dataSet in dataSets) {
      for (var data in dataSet.data) {
        if (data.value < minY) minY = data.value;
        if (data.value > maxY) maxY = data.value;
      }
    }

    // Add some padding to the min and max values
    final double padding = (maxY - minY) * 0.1;
    minY = (minY - padding).clamp(0, double.infinity);
    maxY = (maxY + padding).clamp(0, 100);

    // Calculate nice interval for axis labels
    final double range = maxY - minY;
    final double interval = _calculateNiceInterval(range);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: const TextStyle(fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'series.name - point.x : point.y%',
        shared: true,
      ),
      primaryXAxis: DateTimeAxis(
        axisLine: const AxisLine(width: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        minimum: minY,
        maximum: maxY,
        interval: interval,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      series: _buildSeries(),
    );
  }

  double _calculateNiceInterval(double range) {
    const List<double> possibleSteps = [
      0.1,
      0.2,
      0.25,
      0.5,
      1,
      2,
      2.5,
      5,
      10,
      20,
      25,
      50,
      100
    ];
    const int targetSteps = 5;

    double roughStep = range / targetSteps;
    double niceStep = possibleSteps.last;
    for (var step in possibleSteps) {
      if (step >= roughStep) {
        niceStep = step;
        break;
      }
    }

    return niceStep;
  }

  List<CartesianSeries<TimeSeriesData, DateTime>> _buildSeries() {
    return dataSets.map((dataSet) {
      if (showArea) {
        return AreaSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          gradient: dataSet.gradient,
          borderColor: dataSet.color,
          borderWidth: 2,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
            color: dataSet.color,
          ),
        );
      } else {
        return LineSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          color: dataSet.color,
          width: 2,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
            color: dataSet.color,
          ),
        );
      }
    }).toList();
  }
}

class TimeSeriesData {
  final DateTime time;
  final double value;

  TimeSeriesData(this.time, this.value);
}

class TimeSeriesDataSet {
  final String name;
  final List<TimeSeriesData> data;
  final Color color;
  final LinearGradient? gradient;

  TimeSeriesDataSet({
    required this.name,
    required this.data,
    required this.color,
    this.gradient,
  });
}
