// lib/widgets/monitoring_pages/infobox_overlay.dart
//CHANGE
import 'package:flutter/material.dart';

import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';

import '../graphs/time_series_chart.dart';
import '../graphs/donut_chart.dart';
import '../graphs/combination_chart.dart';
import '../monitoring_pages/graph_section.dart';

class InfoBoxOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const InfoBoxOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<InfoBoxOverlay> createState() => _InfoBoxOverlayState();
}

class _InfoBoxOverlayState extends State<InfoBoxOverlay> {
  @override
  Widget build(BuildContext context) {
    // ✅ OLD STYLE: custom graphs list (static/custom data)
    final List<Widget> growthGraphs = [
      // 1) Time Series Graph (example nutrient trend)
      TimeSeriesChart(
        dataSets: [
          TimeSeriesDataSet(
            name: 'Nitrogen',
            data: [
              TimeSeriesData(DateTime(2025, 4, 1), 35),
              TimeSeriesData(DateTime(2025, 4, 8), 45),
              TimeSeriesData(DateTime(2025, 4, 15), 60),
              TimeSeriesData(DateTime(2025, 4, 22), 70),
              TimeSeriesData(DateTime(2025, 4, 29), 65),
            ],
            color: Colors.green,
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          TimeSeriesDataSet(
            name: 'Phosphorus',
            data: [
              TimeSeriesData(DateTime(2025, 4, 1), 45),
              TimeSeriesData(DateTime(2025, 4, 8), 50),
              TimeSeriesData(DateTime(2025, 4, 15), 40),
              TimeSeriesData(DateTime(2025, 4, 22), 45),
              TimeSeriesData(DateTime(2025, 4, 29), 55),
            ],
            color: Colors.blue,
          ),
          TimeSeriesDataSet(
            name: 'Potassium',
            data: [
              TimeSeriesData(DateTime(2025, 4, 1), 55),
              TimeSeriesData(DateTime(2025, 4, 8), 60),
              TimeSeriesData(DateTime(2025, 4, 15), 65),
              TimeSeriesData(DateTime(2025, 4, 22), 50),
              TimeSeriesData(DateTime(2025, 4, 29), 60),
            ],
            color: Colors.orange,
          ),
        ],
        showMarkers: true,
        showArea: false,
      ),

      // 2) Donut chart (example growth stages)
      DonutChart(
        data: [
          DonutChartData('Early Growth', 45, Colors.lightGreen[300]!),
          DonutChartData('Leafy Growth', 30, Colors.green[400]!),
          DonutChartData('Head Formation', 56, Colors.amber[300]!),
          DonutChartData('Harvest Stage', 12, Colors.orange[400]!),
        ],
        title: 'Plant Growth Stages',
        showLegend: true,
        showLabels: true,
        enableTooltip: true,
      ),

      // 3) Combination Chart (example env vs growth)
      CombinationChart(
        data: [
          CombinationChartData('Week 1', 22.5, 26.2),
          CombinationChartData('Week 2', 28.1, 28.5),
          CombinationChartData('Week 3', 35.4, 29.8),
          CombinationChartData('Week 4', 42.0, 27.1),
          CombinationChartData('Week 5', 48.3, 25.9),
          CombinationChartData('Week 6', 54.7, 26.8),
          CombinationChartData('Week 7', 61.2, 28.2),
          CombinationChartData('Week 8', 68.9, 26.5),
        ],
        title: "Environmental Factors vs Plant Growth",
        xAxisTitle: "Time Period",
        yAxisTitle: "Growth (%)",
      ),
    ];

    return GestureDetector(
      onTap: widget.onClose, // tap outside closes
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // block inside taps from closing
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.8,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Growth Summary',
                        style: TextStyles.elevatedCardTitle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // ✅ OLD STYLE: static stat cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: Icons.eco,
                        value: '14',
                        label: 'Total Plants',
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        icon: Icons.trending_up,
                        value: '78%',
                        label: 'Avg Growth',
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        icon: Icons.science,
                        value: '6.2',
                        label: 'pH Level',
                        color: Colors.deepPurple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ✅ OLD STYLE: custom graphs section
                  Expanded(
                    child: GraphsSection(
                      title: 'Growth Analytics',
                      graphs: growthGraphs,
                      height: double.infinity,
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Footer gradient bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightGreen[300]!,
                          Colors.green[400]!,
                          Colors.amber[300]!,
                          Colors.orange[400]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
