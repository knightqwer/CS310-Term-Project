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
        .snapshots()
        .map((s) {
          final list = s.docs.map(Event.fromFirestore).toList();
          list.sort((a, b) {
            final ad = a.createdAt;
            final bd = b.createdAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });
          return list;
        });
  }

  Stream<List<Event>> registeredByUser(String uid) {
    return _events
        .where('attendeeUids', arrayContains: uid)
        .snapshots()
        .map((s) {
          final list = s.docs.map(Event.fromFirestore).toList();
          list.sort((a, b) {
            final ad = a.dateTime;
            final bd = b.dateTime;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return ad.compareTo(bd);
          });
          return list;
        });
  }

  Stream<List<Event>> pastAttendedByUser(String uid) {
    final now = DateTime.now();
    return _events
        .where('attendeeUids', arrayContains: uid)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map(Event.fromFirestore)
              .where((e) => e.dateTime != null && e.dateTime!.isBefore(now))
              .toList();
          list.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
          return list;
        });
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
