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
    final List<_ChartData> chartData = List.generate(
      values.length,
      (index) => _ChartData(titles[index], values[index], colors[index]),
    );

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pie Chart (No internal legend)
          SizedBox(
            width: 200,
            height: 200,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData data, _) => data.title,
                  yValueMapper: (_ChartData data, _) => data.value,
                  pointColorMapper: (_ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24), // Space between chart and legend

          // Custom Legend
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(titles.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      titles[index],
                      style: TextStyles.elevatedCardDescription,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String title;
  final double value;
  final Color color;

  _ChartData(this.title, this.value, this.color);
}
