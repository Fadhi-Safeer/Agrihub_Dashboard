import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHistoryService {
  final FirebaseFirestore _db;

  FirestoreHistoryService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Stream last [days] of device history docs.
  Stream<QuerySnapshot<Map<String, dynamic>>> historyStream({
    required String appId,
    int days = 30,
    int limit = 5000,
  }) {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));

    return _db
        .collection('artifacts')
        .doc(appId)
        .collection('device_history')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .orderBy('timestamp', descending: false)
        .limit(limit)
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snap, _) => (snap.data() ?? <String, dynamic>{}),
          toFirestore: (data, _) => data,
        )
        .snapshots();
  }

  /// Read numeric value from record['readings'] using possible aliases.
  double? getReadingValue(
      Map<String, dynamic> record, List<String> possibleKeys) {
    final readings = record['readings'];
    if (readings is! Map<String, dynamic>) return null;

    for (final k in possibleKeys) {
      final v = readings[k];
      if (v is num) return v.toDouble();
    }
    return null;
  }
}
