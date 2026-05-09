import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String location;
  final String category;
  final String? organizerUid;
  final List<String> attendeeUids;
  final DateTime? dateTime;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    this.organizerUid,
    this.attendeeUids = const [],
    this.dateTime,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? ts = data['dateTime'] as Timestamp?;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      organizerUid: data['organizerUid'],
      attendeeUids: List<String>.from(data['attendeeUids'] ?? []),
      dateTime: ts?.toDate(),
    );
  }
}
