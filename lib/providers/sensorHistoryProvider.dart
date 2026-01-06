// lib/providers/sensorHistoryProvider.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../services/firestore_history_service.dart';
import '../widgets/graphs/time_series_chart.dart'; // for TimeSeriesData

/// Retrieves Firestore sensor history ONCE and exposes parsed values
/// so multiple pages/graphs can reuse without re-querying.
class SensorHistoryProvider extends ChangeNotifier {
  final FirestoreHistoryService _historyService;
  final String appId;

  final int days;
  final int limit;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  bool _loading = true;
  String? _error;

  List<TimeSeriesData> _tempPoints = const [];
  List<TimeSeriesData> _humidityPoints = const [];
  List<TimeSeriesData> _soilPoints = const [];

  bool get loading => _loading;
  String? get error => _error;

  List<TimeSeriesData> get tempPoints => _tempPoints;
  List<TimeSeriesData> get humidityPoints => _humidityPoints;
  List<TimeSeriesData> get soilPoints => _soilPoints;

  SensorHistoryProvider({
    required this.appId,
    FirestoreHistoryService? historyService,
    this.days = 30,
    this.limit = 5000,
  }) : _historyService = historyService ?? FirestoreHistoryService() {
    _start();
  }

  void _start() {
    _loading = true;
    _error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _historyService
        .historyStream(appId: appId, days: days, limit: limit)
        .listen(
      (snapshot) {
        try {
          final docs = snapshot.docs;

          final temp = <TimeSeriesData>[];
          final hum = <TimeSeriesData>[];
          final soil = <TimeSeriesData>[];

          for (final d in docs) {
            final record = d.data();

            final ts = record['timestamp'];
            if (ts is! Timestamp) continue;
            final time = ts.toDate();

            final t = _historyService.getReadingValue(record, const [
              'Temperature',
              'environment_temperature',
              'temp',
              'temperature',
            ]);

            final h = _historyService.getReadingValue(record, const [
              'Humidity',
              'environment_humidity',
              'hum',
              'humidity',
            ]);

            final s = _historyService.getReadingValue(record, const [
              'Soil Moisture',
              'Soil_Moisture',
              'soil_moisture',
              'soilMoisture',
              'moisture',
            ]);

            if (t != null) temp.add(TimeSeriesData(time, t));
            if (h != null) hum.add(TimeSeriesData(time, h));
            if (s != null) soil.add(TimeSeriesData(time, s));
          }

          // Replace lists (immutable assignment helps UI rebuild cleanly)
          _tempPoints = temp;
          _humidityPoints = hum;
          _soilPoints = soil;

          _loading = false;
          _error = null;
          notifyListeners();
        } catch (e) {
          _loading = false;
          _error = e.toString();
          notifyListeners();
        }
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  /// Optional: call this if you want to change date range/limit at runtime
  /// (e.g., user selects 7 days vs 30 days).
  void refresh() {
    _start();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
