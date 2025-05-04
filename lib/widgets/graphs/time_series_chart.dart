import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MultiGradientLineChart extends StatelessWidget {
  final List<TimeSeriesDataSet> dataSets;
  final bool showMarkers;
  final bool showArea;

  const MultiGradientLineChart({
    super.key,
    required this.dataSets,
    this.showMarkers = true,
    this.showArea = false,
  });

  @override
  Widget build(BuildContext context) {
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
        minimum: 0,
        maximum: 100,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      series: _buildSeries(),
    );
  }

  List<CartesianSeries<TimeSeriesData, DateTime>> _buildSeries() {
    return dataSets.map((dataSet) {
      if (showArea) {
        return SplineAreaSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          gradient: dataSet.gradient,
          borderColor: dataSet.color,
          borderWidth: 2,
          splineType: SplineType.cardinal,
          markerSettings: MarkerSettings(
            isVisible: showMarkers,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
            color: dataSet.color,
          ),
        );
      } else {
        return SplineSeries<TimeSeriesData, DateTime>(
          name: dataSet.name,
          dataSource: dataSet.data,
          xValueMapper: (d, _) => d.time,
          yValueMapper: (d, _) => d.value,
          color: dataSet.color,
          width: 2,
          splineType: SplineType.cardinal,
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
