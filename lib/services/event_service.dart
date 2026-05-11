import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final _events = FirebaseFirestore.instance.collection('events');

  Stream<List<Event>> upcomingEvents() {
    return _events
        .where('dateTime', isGreaterThan: Timestamp.now())
        .orderBy('dateTime')
        .snapshots()
        .map((s) => s.docs.map(Event.fromFirestore).toList());
  }

  Stream<List<Event>> createdByUser(String uid) {
    return _events
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Event.fromFirestore).toList());
  }

  Stream<List<Event>> registeredByUser(String uid) {
    return _events
        .where('attendeeUids', arrayContains: uid)
        .orderBy('dateTime')
        .snapshots()
        .map((s) => s.docs.map(Event.fromFirestore).toList());
  }

  Stream<List<Event>> pastAttendedByUser(String uid) {
    return _events
        .where('attendeeUids', arrayContains: uid)
        .where('dateTime', isLessThan: Timestamp.now())
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Event.fromFirestore).toList());
  }

  Future<DocumentReference> createEvent(Map<String, dynamic> data) {
    return _events.add(data);
  }

  Future<void> registerForEvent(String eventId, String uid) {
    return _events.doc(eventId).update({
      'attendeeUids': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> unregisterFromEvent(String eventId, String uid) {
    return _events.doc(eventId).update({
      'attendeeUids': FieldValue.arrayRemove([uid]),
    });
  }
}
