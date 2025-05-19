import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DonutChartData {
  final String stage;
  final double count;
  final Color color;

  DonutChartData(this.stage, this.count, this.color);
}

class DonutChart extends StatelessWidget {
  final List<DonutChartData> data;
  final String? title;
  final bool showLegend;
  final bool showLabels;
  final double innerRadius;
  final bool enableTooltip;

  const DonutChart({
    super.key,
    required this.data,
    this.title,
    this.showLegend = true,
    this.showLabels = true,
    this.innerRadius = 50,
    this.enableTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    if (title != null && title!.isNotEmpty) {}
    return SfCircularChart(
      title: (title != null && title!.isNotEmpty)
          ? ChartTitle(text: title!)
          : ChartTitle(text: ''),
      legend: Legend(
        isVisible: showLegend,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode
            .scroll, // Make the legend scrollable horizontally
        textStyle: const TextStyle(fontSize: 12),
        isResponsive:
            true, // Makes the legend more responsive on different screen sizes
      ),
      tooltipBehavior: TooltipBehavior(enable: enableTooltip),
      series: <DoughnutSeries<DonutChartData, String>>[
        DoughnutSeries<DonutChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.stage,
          yValueMapper: (d, _) => d.count,
          pointColorMapper: (d, _) => d.color,
          innerRadius: '$innerRadius%',
          dataLabelSettings: DataLabelSettings(
            isVisible: showLabels,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
