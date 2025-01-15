import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TimeSeriesLineChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Hide Y-axis titles
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      'T${value.toInt()}',
                      style: TextStyle(
                          color: Colors.white), // Set text color to white
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minY: 0,
            maxY: 10, // Set the Y-axis range to 10
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 10),
                  FlSpot(1, 15),
                  FlSpot(2, 12),
                  FlSpot(3, 18),
                  FlSpot(4, 20),
                ],
                isCurved: false, // Set to false to make lines straight
                color: Color(0xFF2ADAD4), // Use specified color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, 8),
                  FlSpot(1, 10),
                  FlSpot(2, 14),
                  FlSpot(3, 13),
                  FlSpot(4, 15),
                ],
                isCurved: false, // Set to false to make lines straight
                color: Color(0xFF3B82F6), // Use specified color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, 5),
                  FlSpot(1, 7),
                  FlSpot(2, 8),
                  FlSpot(3, 10),
                  FlSpot(4, 12),
                ],
                isCurved: false, // Set to false to make lines straight
                color: Color(0xFF9E42DE), // Use specified color
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TimeSeriesLineChart(),
    theme: ThemeData(
      scaffoldBackgroundColor:
          Colors.black, // Set scaffold background color to black
    ),
  ));
}
