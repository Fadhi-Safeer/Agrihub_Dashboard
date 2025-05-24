import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class CombinationChartData {
  final String week;
  final double growthRate;
  final double temperature;

  CombinationChartData(this.week, this.growthRate, this.temperature);
}

class CombinationChart extends StatelessWidget {
  final List<CombinationChartData> data;
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;

  const CombinationChart({
    super.key,
    required this.data,
    this.title = "",
    this.xAxisTitle = "",
    this.yAxisTitle = "",
  });

  @override
  Widget build(BuildContext context) {
    // Extract growth and temperature values
    final growthRates = data.map((d) => d.growthRate).toList();
    final temperatures = data.map((d) => d.temperature).toList();

    // Dynamic min and max for growth rate
    final double minGrowth = growthRates.reduce(min);
    final double maxGrowth = growthRates.reduce(max);
    final double growthRange = maxGrowth - minGrowth;
    final double growthInterval = _getDynamicInterval(growthRange);

    final double adjustedMinGrowth =
        (minGrowth / growthInterval).floorToDouble() * growthInterval;
    final double adjustedMaxGrowth =
        (maxGrowth / growthInterval).ceilToDouble() * growthInterval;

    // Dynamic min and max for temperature
    final double minTemp = temperatures.reduce(min);
    final double maxTemp = temperatures.reduce(max);
    final double tempRange = maxTemp - minTemp;
    final double tempInterval = _getDynamicInterval(tempRange);

    final double adjustedMinTemp =
        (minTemp / tempInterval).floorToDouble() * tempInterval;
    final double adjustedMaxTemp =
        (maxTemp / tempInterval).ceilToDouble() * tempInterval;

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(
        text: title.isEmpty ? 'Growth Rate vs Temperature' : title,
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        textStyle: const TextStyle(fontSize: 12),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: xAxisTitle),
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: yAxisTitle.isEmpty ? 'Growth Rate (cm/week)' : yAxisTitle,
        ),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        minimum: adjustedMinGrowth,
        maximum: adjustedMaxGrowth,
        interval: growthInterval,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      axes: <ChartAxis>[
        NumericAxis(
          name: 'tempAxis',
          opposedPosition: true,
          title: AxisTitle(text: 'Temperature (°C)'),
          minimum: adjustedMinTemp,
          maximum: adjustedMaxTemp,
          interval: tempInterval,
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
        )
      ],
      series: <CartesianSeries>[
        ColumnSeries<CombinationChartData, String>(
          name: 'Growth Rate',
          dataSource: data,
          xValueMapper: (d, _) => d.week,
          yValueMapper: (d, _) => d.growthRate,
          color: Colors.green.withOpacity(0.7),
        ),
        LineSeries<CombinationChartData, String>(
          name: 'Temperature',
          dataSource: data,
          xValueMapper: (d, _) => d.week,
          yValueMapper: (d, _) => d.temperature,
          yAxisName: 'tempAxis',
          color: Colors.red,
          width: 2,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  double _getDynamicInterval(double range) {
    // Ensure at least 5 intervals
    const int minIntervals = 5;
    double roughInterval = range / minIntervals;

    // Round interval to a nice number (1, 2, 5, 10, etc.)
    double magnitude = pow(10, (log(roughInterval) / ln10).floor()).toDouble();
    double residual = roughInterval / magnitude;

    if (residual > 5) {
      roughInterval = 10 * magnitude;
    } else if (residual > 2) {
      roughInterval = 5 * magnitude;
    } else if (residual > 1) {
      roughInterval = 2 * magnitude;
    } else {
      roughInterval = 1 * magnitude;
    }

    return roughInterval;
  }
}
