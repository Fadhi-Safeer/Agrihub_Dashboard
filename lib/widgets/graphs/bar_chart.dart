import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class GroupedBarChart extends StatefulWidget {
  @override
  _GroupedBarChartState createState() => _GroupedBarChartState();
}

Color colour1 = AppColors.neonCyan;
Color colour2 = AppColors.neonPink;
Color colour3 = AppColors.neonOrange;

class _GroupedBarChartState extends State<GroupedBarChart> {
  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Usage Optimization',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 20,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (touchedGroupIndex == group.x) {
                                return BarTooltipItem(
                                  rod.toY.toString(),
                                  TextStyle(color: Colors.white),
                                );
                              }
                              return null;
                            },
                          ),
                          touchCallback:
                              (FlTouchEvent event, barTouchResponse) {
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
                                    return Text('Week 1',
                                        style: TextStyle(color: Colors.white));
                                  case 1:
                                    return Text('Week 2',
                                        style: TextStyle(color: Colors.white));
                                  case 2:
                                    return Text('Week 3',
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
                            barsSpace: 0,
                            barRods: [
                              BarChartRodData(
                                  toY: 17,
                                  color: colour1,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 22,
                                  color: colour2,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 18,
                                  color: colour3,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                            ],
                            showingTooltipIndicators:
                                touchedGroupIndex == 0 ? [0, 1, 2] : [],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barsSpace: 0,
                            barRods: [
                              BarChartRodData(
                                  toY: 15,
                                  color: colour1,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 17,
                                  color: colour2,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 18,
                                  color: colour3,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                            ],
                            showingTooltipIndicators:
                                touchedGroupIndex == 1 ? [0, 1, 2] : [],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barsSpace: 0,
                            barRods: [
                              BarChartRodData(
                                  toY: 25,
                                  color: colour1,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 28,
                                  color: colour2,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                              BarChartRodData(
                                  toY: 17,
                                  color: colour3,
                                  width: 17,
                                  borderRadius: BorderRadius.zero),
                            ],
                            showingTooltipIndicators:
                                touchedGroupIndex == 2 ? [0, 1, 2] : [],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Indicators
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Indicator(
                        color: colour1,
                        text: 'Moisture',
                        isSquare: true,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: colour2,
                        text: 'Nutrients',
                        isSquare: true,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: colour3,
                        text: 'Energy',
                        isSquare: true,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = Colors.white70,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
          ),
        )
      ],
    );
  }
}
