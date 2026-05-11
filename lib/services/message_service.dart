import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class MessageService {
  CollectionReference _messages(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('messages');
  }

  Stream<List<Message>> messagesStream(String eventId) {
    return _messages(eventId)
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(Message.fromFirestore).toList());
  }

  Future<void> sendMessage(String eventId, Map<String, dynamic> data) {
    return _messages(eventId).add(data);
  }
}
