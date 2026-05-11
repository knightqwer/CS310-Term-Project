import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  final _reports = FirebaseFirestore.instance.collection('reports');

  Future<DocumentReference> submitReport({
    required String reporterUid,
    required String reportedUsername,
    required String reason,
    required String details,
  }) {
    return _reports.add({
      'reporterUid': reporterUid,
      'reportedUsername': reportedUsername,
      'reason': reason,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
