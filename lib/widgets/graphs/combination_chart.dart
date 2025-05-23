import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      title: ChartTitle(
          text: title.isEmpty ? 'Health Rate vs Temperature' : title),
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
            text: yAxisTitle.isEmpty ? 'Disease Rate (cm/week)' : yAxisTitle),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.black12),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      axes: <ChartAxis>[
        NumericAxis(
          name: 'tempAxis',
          opposedPosition: true,
          title: AxisTitle(text: 'Temperature (°C)'),
          minimum: 15,
          maximum: 35,
          interval: 5,
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
}
