import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String imageUrl;
  final String status; // "upcoming" | "past"
  final DateTime? dateTime;
  final String location;
  final String organizer;
  final String organizerUid;
  final int attendeeCount;
  final int maxAttendees;
  final String description;
  final String category;
  final List<String> tags;
  final List<String> attendeeUids;
  final String createdBy;
  final DateTime? createdAt;

  const Event({
    required this.id,
    required this.title,
    this.imageUrl = '',
    this.status = 'upcoming',
    this.dateTime,
    required this.location,
    this.organizer = '',
    this.organizerUid = '',
    this.attendeeCount = 0,
    this.maxAttendees = 0,
    this.description = '',
    this.category = '',
    this.tags = const [],
    this.attendeeUids = const [],
    this.createdBy = '',
    this.createdAt,
  });

  String get date {
    if (dateTime == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime!.month - 1]} ${dateTime!.day}, ${dateTime!.year}';
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp? dtTs = data['dateTime'] as Timestamp?;
    final Timestamp? caTs = data['createdAt'] as Timestamp?;
    return Event(
      id: doc.id,
      title: data['title'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      status: data['status'] as String? ?? 'upcoming',
      dateTime: dtTs?.toDate(),
      location: data['location'] as String? ?? '',
      organizer: data['organizer'] as String? ?? '',
      organizerUid: data['organizerUid'] as String? ?? '',
      attendeeCount: (data['attendeeCount'] as int?) ?? 0,
      maxAttendees: (data['maxAttendees'] as int?) ?? 0,
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      tags: List<String>.from(data['tags'] as List? ?? []),
      attendeeUids: List<String>.from(data['attendeeUids'] as List? ?? []),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: caTs?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'status': status,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'location': location,
      'organizer': organizer,
      'organizerUid': organizerUid,
      'attendeeCount': attendeeCount,
      'maxAttendees': maxAttendees,
      'description': description,
      'category': category,
      'tags': tags,
      'attendeeUids': attendeeUids,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
