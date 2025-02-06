import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GroupedBarChart extends StatefulWidget {
  @override
  _GroupedBarChartState createState() => _GroupedBarChartState();
}

class _GroupedBarChartState extends State<GroupedBarChart> {
  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 0, 0, 0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)), // No rounding
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grouped Bar Chart', // Add a small heading
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10), // Small space between title and graph
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment:
                      BarChartAlignment.spaceBetween, // Space between groups
                  maxY: 20,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          rod.toY.toString(), // Display value when hovered
                          TextStyle(color: Colors.white),
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          touchedGroupIndex = -1;
                          return;
                        }
                        touchedGroupIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text('Group 1',
                                  style: TextStyle(color: Colors.white));
                            case 1:
                              return Text('Group 2',
                                  style: TextStyle(color: Colors.white));
                            case 2:
                              return Text('Group 3',
                                  style: TextStyle(color: Colors.white));
                            default:
                              return Text('');
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 0, // No space between bars in a group
                      barRods: [
                        BarChartRodData(
                            toY: 8,
                            color: Colors.blue,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 1
                        BarChartRodData(
                            toY: 12,
                            color: Colors.red,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 2
                        BarChartRodData(
                            toY: 14,
                            color: Colors.green,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 3
                      ],
                      showingTooltipIndicators:
                          touchedGroupIndex == 0 ? [0, 1, 2] : [0, 0, 0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 0, // No space between bars in a group
                      barRods: [
                        BarChartRodData(
                            toY: 10,
                            color: Colors.blue,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 1
                        BarChartRodData(
                            toY: 14,
                            color: Colors.red,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 2
                        BarChartRodData(
                            toY: 13,
                            color: Colors.green,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 3
                      ],
                      showingTooltipIndicators:
                          touchedGroupIndex == 1 ? [0, 1, 2] : [0, 0, 0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 0, // No space between bars in a group
                      barRods: [
                        BarChartRodData(
                            toY: 14,
                            color: Colors.blue,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 1
                        BarChartRodData(
                            toY: 15,
                            color: Colors.red,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 2
                        BarChartRodData(
                            toY: 11,
                            color: Colors.green,
                            width: 20,
                            borderRadius: BorderRadius.zero), // Bar 3
                      ],
                      showingTooltipIndicators:
                          touchedGroupIndex == 2 ? [0, 1, 2] : [0, 0, 0],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
