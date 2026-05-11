import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String? eventId;
  final bool read;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.eventId,
    required this.read,
    this.createdAt,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return NotificationItem(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      eventId: data['eventId'] as String?,
      read: data['read'] as bool? ?? false,
      createdAt: ts?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'eventId': eventId,
      'read': read,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
