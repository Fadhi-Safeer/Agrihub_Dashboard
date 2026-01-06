// lib/widgets/monitoring_pages/infobox_overlay.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/text_styles.dart';
import '../../theme/app_colors.dart';

import '../graphs/donut_chart.dart';
import '../graphs/dual_axis_combo_chart.dart';

import '../../services/firestore_history_service.dart';
import '../../services/api_service.dart';
import '../../services/graph_data_handler.dart';

// ✅ use your globals
import '../../globals.dart'; // adjust path if different

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
  final ApiService _apiService = ApiService(baseUrl: 'http://127.0.0.1:8001');
  late final GraphDataHandler _dataHandler;

  late Future<AgrivisionSummary> _summaryFuture;

  final FirestoreHistoryService _history = FirestoreHistoryService();

  @override
  void initState() {
    super.initState();
    _dataHandler = GraphDataHandler(_apiService);
    _summaryFuture = _dataHandler.fetchAgrivisionSummary(days: 30);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ get appId from globals.dart
// <-- change name if needed

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
                  FutureBuilder<AgrivisionSummary>(
                    future: _summaryFuture,
                    builder: (context, snap) {
                      final loading =
                          snap.connectionState != ConnectionState.done;
                      final hasData = snap.hasData && snap.data != null;

                      final totalDetections =
                          hasData ? snap.data!.totalCount : 0;
                      final healthyCount =
                          hasData ? snap.data!.healthyCount : 0;
                      final diseaseCount =
                          hasData ? snap.data!.diseaseTotalCount : 0;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            icon: Icons.camera_alt,
                            value: loading ? '...' : '$totalDetections',
                            label: 'Detections',
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            icon: Icons.favorite,
                            value: loading ? '...' : '$healthyCount',
                            label: 'Healthy',
                            color: Colors.blue,
                          ),
                          _buildStatCard(
                            icon: Icons.warning_amber_rounded,
                            value: loading ? '...' : '$diseaseCount',
                            label: 'Disease',
                            color: Colors.deepPurple,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Graphs (3 stacked)
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _history.historyStream(
                        appId: appId,
                        days: 30,
                        limit: 5000,
                      ),
                      builder: (context, historySnap) {
                        if (historySnap.hasError) {
                          return Center(
                            child: Text(
                              'Firestore error:\n${historySnap.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (!historySnap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final docs = historySnap.data!.docs;

                        final pointsTempGrowth = <DualAxisPoint>[];
                        final pointsHumGrowth = <DualAxisPoint>[];

                        for (final d in docs) {
                          final r = d.data();

                          final ts = r['timestamp'];
                          if (ts is! Timestamp) continue;
                          final time = ts.toDate();

                          final growth = _history.getReadingValue(r, [
                            'growth',
                            'growth_value',
                            'growthScore',
                            'growth_score',
                          ]);

                          final temp = _history.getReadingValue(r, [
                            'temp',
                            'temperature',
                            'temperature_c',
                            'temp_c',
                          ]);

                          final hum = _history.getReadingValue(r, [
                            'humidity',
                            'hum',
                            'humidity_percent',
                          ]);

                          if (growth != null && temp != null) {
                            pointsTempGrowth
                                .add(DualAxisPoint(time, temp, growth));
                          }
                          if (growth != null && hum != null) {
                            pointsHumGrowth
                                .add(DualAxisPoint(time, hum, growth));
                          }
                        }

                        pointsTempGrowth
                            .sort((a, b) => a.time.compareTo(b.time));
                        pointsHumGrowth
                            .sort((a, b) => a.time.compareTo(b.time));

                        return FutureBuilder<AgrivisionSummary>(
                          future: _summaryFuture,
                          builder: (context, summarySnap) {
                            if (summarySnap.hasError) {
                              return Center(
                                child: Text(
                                  'API error:\n${summarySnap.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            if (!summarySnap.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final summary = summarySnap.data!;

                            final growthPalette = <Color>[
                              Colors.green.shade400,
                              Colors.orange.shade400,
                              Colors.blue.shade400,
                              Colors.purple.shade400,
                              Colors.red.shade400,
                            ];

                            final growthDonut = GraphDataHandler.toDonutData(
                              classes: summary.growthClasses,
                              counts: summary.growthCounts,
                              palette: growthPalette,
                            );

                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  _graphCard(
                                    child: DonutChart(
                                      data: growthDonut,
                                      title: 'Growth (Nutrition Classes)',
                                      showLegend: true,
                                      showLabels: true,
                                      enableTooltip: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _graphCard(
                                    height: 280,
                                    child: DualAxisComboChart(
                                      title: 'Temperature vs Growth',
                                      leftName: 'Temperature (°C)',
                                      rightName: 'Growth (%)',
                                      points: pointsTempGrowth,
                                      growthIsRatio: true,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _graphCard(
                                    height: 280,
                                    child: DualAxisComboChart(
                                      title: 'Humidity vs Growth',
                                      leftName: 'Humidity (%)',
                                      rightName: 'Growth (%)',
                                      points: pointsHumGrowth,
                                      growthIsRatio: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

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

  Widget _graphCard({required Widget child, double? height}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
