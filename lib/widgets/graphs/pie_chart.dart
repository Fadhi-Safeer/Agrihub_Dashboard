import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../theme/text_styles.dart';

class CustomPieChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> titles;

  const CustomPieChart({
    Key? key,
    required this.values,
    required this.colors,
    required this.titles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a list of chart data from the input
    final List<_ChartData> chartData = List.generate(
      values.length,
      (index) => _ChartData(titles[index], values[index], colors[index]),
    );

    return SfCircularChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        textStyle: TextStyles.elevatedCardDescription,
        overflowMode: LegendItemOverflowMode.wrap,
        alignment: ChartAlignment.center,
        // Add this for spacing
        offset: const Offset(5, 0),
      ),
      series: <CircularSeries>[
        PieSeries<_ChartData, String>(
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.title,
          yValueMapper: (_ChartData data, _) => data.value,
          pointColorMapper: (_ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }
}

class _ChartData {
  final String title;
  final double value;
  final Color color;

  _ChartData(this.title, this.value, this.color);
}
