import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/notification_item.dart';

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  Stream<AppUser?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromFirestore(doc);
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).update(data);
  }

  Stream<List<NotificationItem>> notificationsStream(String uid) {
    return _users
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NotificationItem.fromFirestore).toList());
  }
}
