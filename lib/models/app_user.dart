import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String bio;
  final int attendingCount;
  final int eventsCreated;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.attendingCount,
    required this.eventsCreated,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      attendingCount: (data['attendingCount'] as int?) ?? 0,
      eventsCreated: (data['eventsCreated'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'bio': bio,
      'attendingCount': attendingCount,
      'eventsCreated': eventsCreated,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? bio,
    int? attendingCount,
    int? eventsCreated,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      bio: bio ?? this.bio,
      attendingCount: attendingCount ?? this.attendingCount,
      eventsCreated: eventsCreated ?? this.eventsCreated,
    );
  }
}
