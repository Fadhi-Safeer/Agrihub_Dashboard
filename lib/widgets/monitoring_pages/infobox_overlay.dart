import 'package:flutter/material.dart';
import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';
import '../graphs/area_chart.dart';
import '../graphs/combination_chart.dart';
import '../graphs/donut_chart.dart';
import '../graphs/time_series_chart.dart';
import '../monitoring_pages/graph_section.dart';
import '../../services/api_service.dart';
import '../../services/graph_data_handler.dart';

class InfoBoxOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const InfoBoxOverlay({super.key, required this.onClose});

  @override
  _InfoBoxOverlayState createState() => _InfoBoxOverlayState();
}

class _InfoBoxOverlayState extends State<InfoBoxOverlay> {
  final ApiService _apiService = ApiService(baseUrl: 'http://127.0.0.1:8002');
  late GraphDataHandler _dataHandler;

  bool _isLoadingGrowthStages = true;
  String _growthStagesError = '';
  List<ChartData> _growthStagesData = [];

  @override
  void initState() {
    super.initState();
    _dataHandler = GraphDataHandler(_apiService);
    _loadGrowthStageData();
  }

  Future<void> _loadGrowthStageData() async {
    try {
      final data = await _dataHandler.fetchGrowthStageTimelineData();

      final List<String> labels = List<String>.from(data['labels']);
      final List<double> earlyGrowth = List<double>.from(data['early_growth']);
      final List<double> leafyGrowth = List<double>.from(data['leafy_growth']);
      final List<double> headFormation =
          List<double>.from(data['head_formation']);
      final List<double> harvestStage =
          List<double>.from(data['harvest_stage']);

      if (labels.isEmpty ||
          earlyGrowth.length != labels.length ||
          leafyGrowth.length != labels.length ||
          headFormation.length != labels.length ||
          harvestStage.length != labels.length) {
        throw Exception('Data length mismatch or empty data received');
      }

      setState(() {
        _growthStagesData = List.generate(labels.length, (i) {
          return ChartData(
            labels[i],
            earlyGrowth[i],
            leafyGrowth[i],
            headFormation[i],
            harvestStage[i],
          );
        });
        _isLoadingGrowthStages = false;
      });
    } catch (e) {
      setState(() {
        _growthStagesError = 'Error: $e';
        _isLoadingGrowthStages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> growthGraphs = [
      // Time Series Graph
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

      // Donut chart
      DonutChart(
        data: [
          DonutChartData('Early Growth', 10, Colors.lightGreen[300]!),
          DonutChartData('Leafy Growth', 15, Colors.green[400]!),
          DonutChartData('Head Formation', 8, Colors.amber[300]!),
          DonutChartData('Harvest Stage', 12, Colors.orange[400]!),
        ],
        title: 'Plant Growth Stages',
        showLegend: true,
        showLabels: true,
        enableTooltip: true,
      ),

      // Stacked area chart from API
      if (_isLoadingGrowthStages)
        const Center(child: CircularProgressIndicator())
      else if (_growthStagesError.isNotEmpty)
        Center(child: Text(_growthStagesError))
      else
        StackedAreaChart(
          seriesData: _growthStagesData,
          xAxisTitle: '',
          yAxisTitle: '',
          seriesColors: [
            Colors.lightGreen[300]!,
            Colors.green[400]!,
            Colors.amber[300]!,
            Colors.orange[400]!,
          ],
        ),

      // Combination Chart
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
      )
    ];

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
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

                  // Stat cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        icon: Icons.eco,
                        value: '345',
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
                        icon: Icons.calendar_today,
                        value: '12',
                        label: 'Harvest Days',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Graphs section
                  Expanded(
                    child: GraphsSection(
                      title: 'Growth Analytics',
                      graphs: growthGraphs,
                      height: double.infinity,
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Progress bar
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
