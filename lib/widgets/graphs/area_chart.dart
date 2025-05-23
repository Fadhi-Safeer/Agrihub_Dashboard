import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StackedAreaChart extends StatelessWidget {
  final String xAxisTitle;
  final String yAxisTitle;
  final List<ChartData> seriesData;
  final List<Color> seriesColors;

  StackedAreaChart({
    required this.xAxisTitle,
    required this.yAxisTitle,
    required this.seriesData,
    required this.seriesColors,
  });

  @override
  Widget build(BuildContext context) {
    double maxY = [
      ...seriesData.map((e) => e.series1),
      ...seriesData.map((e) => e.series2),
      ...seriesData.map((e) => e.series3),
      ...seriesData.map((e) => e.series4),
    ].reduce((a, b) => a > b ? a : b);

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      primaryXAxis: CategoryAxis(
        title: xAxisTitle.isEmpty
            ? AxisTitle(text: '')
            : AxisTitle(text: xAxisTitle),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: yAxisTitle),
        minimum: 0,
        maximum: maxY + 5,
        interval: 5,
      ),
      series: <CartesianSeries>[
        StackedAreaSeries<ChartData, String>(
          dataSource: seriesData,
          xValueMapper: (ChartData data, _) => data.day,
          yValueMapper: (ChartData data, _) => data.series1,
          name: 'Series 1',
          borderWidth: 2,
          color: seriesColors[0],
        ),
        StackedAreaSeries<ChartData, String>(
          dataSource: seriesData,
          xValueMapper: (ChartData data, _) => data.day,
          yValueMapper: (ChartData data, _) => data.series2,
          name: 'Series 2',
          borderWidth: 2,
          color: seriesColors[1],
        ),
        StackedAreaSeries<ChartData, String>(
          dataSource: seriesData,
          xValueMapper: (ChartData data, _) => data.day,
          yValueMapper: (ChartData data, _) => data.series3,
          name: 'Series 3',
          borderWidth: 2,
          color: seriesColors[2],
        ),
        StackedAreaSeries<ChartData, String>(
          dataSource: seriesData,
          xValueMapper: (ChartData data, _) => data.day,
          yValueMapper: (ChartData data, _) => data.series4,
          name: 'Series 4',
          borderWidth: 2,
          color: seriesColors[3],
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.day, this.series1, this.series2, this.series3, this.series4);

  final String day;
  final double series1;
  final double series2;
  final double series3;
  final double series4;
}
