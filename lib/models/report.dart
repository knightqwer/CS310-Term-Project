import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String reporterUid;
  final String reportedUid;
  final String reason;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.reporterUid,
    required this.reportedUid,
    required this.reason,
    this.createdAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return Report(
      id: doc.id,
      reporterUid: data['reporterUid'] as String? ?? '',
      reportedUid: data['reportedUid'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      createdAt: ts?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
