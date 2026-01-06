// lib/services/graph_data_handler.dart
import 'package:flutter/material.dart';
import '../widgets/graphs/donut_chart.dart';
import 'api_service.dart';

class AgrivisionSummary {
  final List<String> growthClasses;
  final List<int> growthCounts;

  final List<String> healthClasses;
  final List<int> healthCounts;

  final List<String> diseaseClasses;
  final List<int> diseaseCounts;

  AgrivisionSummary({
    required this.growthClasses,
    required this.growthCounts,
    required this.healthClasses,
    required this.healthCounts,
    required this.diseaseClasses,
    required this.diseaseCounts,
  });

  /// ✅ Parse backend JSON
  factory AgrivisionSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) =>
        (json[key] as Map).cast<String, dynamic>();

    List<String> classesOf(String key) =>
        List<String>.from(section(key)['classes'] as List);

    List<int> countsOf(String key) =>
        List<dynamic>.from(section(key)['counts'] as List)
            .map((e) => (e as num).toInt())
            .toList();

    return AgrivisionSummary(
      growthClasses: classesOf('growth'),
      growthCounts: countsOf('growth'),
      healthClasses: classesOf('health'),
      healthCounts: countsOf('health'),
      diseaseClasses: classesOf('disease'),
      diseaseCounts: countsOf('disease'),
    );
  }

  // ✅ TOTAL detections (all rows)
  int get totalCount => growthCounts.fold(0, (a, b) => a + b);

  // ✅ HEALTHY count (derived from health section)
  int get healthyCount {
    for (int i = 0; i < healthClasses.length; i++) {
      if (healthClasses[i].toLowerCase() == 'healthy') {
        return healthCounts[i];
      }
    }
    return 0;
  }

  // ✅ TOTAL disease cases (sum of disease counts)
  int get diseaseTotalCount => diseaseCounts.fold(0, (a, b) => a + b);
}

class GraphDataHandler {
  final ApiService _api;
  GraphDataHandler(this._api);

  Future<AgrivisionSummary> fetchAgrivisionSummary({
    int days = 30,
    int? cameraId,
    String? day,
  }) async {
    final json = await _api.fetchAgrivisionSummary(
      days: days,
      cameraId: cameraId,
      day: day,
    );
    return AgrivisionSummary.fromJson(json);
  }

  /// Convert a summary section into DonutChartData list (UI-ready)
  static List<DonutChartData> toDonutData({
    required List<String> classes,
    required List<int> counts,
    required List<Color> palette,
  }) {
    final out = <DonutChartData>[];
    final n = classes.length < counts.length ? classes.length : counts.length;

    for (int i = 0; i < n; i++) {
      out.add(
        DonutChartData(
          classes[i],
          counts[i].toDouble(),
          palette[i % palette.length],
        ),
      );
    }
    return out;
  }
}
