import 'package:cloud_firestore/cloud_firestore.dart';
import '../globals.dart';

class SensorHistoryRepository {
  final FirebaseFirestore _db;

  SensorHistoryRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> rawHistoryStream({
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
}
