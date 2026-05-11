import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String reporterUid;
  final String reportedUsername;
  final String reason;
  final String details;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.reporterUid,
    required this.reportedUsername,
    required this.reason,
    required this.details,
    this.createdAt,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return Report(
      id: doc.id,
      reporterUid: data['reporterUid'] as String? ?? '',
      reportedUsername: data['reportedUsername'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      details: data['details'] as String? ?? '',
      createdAt: ts?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterUid': reporterUid,
      'reportedUsername': reportedUsername,
      'reason': reason,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
