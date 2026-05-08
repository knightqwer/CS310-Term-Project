import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// this is the main auth class for the whole app
// it extends changenotifier so any widget listening to it rebuilds when something changes
// the state mgmt guy needs to register this inside his multiprovider tree in main.dart

class AuthProvider extends ChangeNotifier {

  // firebaseauth is what we use to login logout register etc
  // firestore is for creating and updating user documents in the database
  // TODO: the architecture guy is building a full service layer in lib/services
  // but auth state needs to live here at the provider level so we access firebase directly
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // this stores whoever is currently logged in
  // it's null when nobody is logged in
  User? _currentUser;

  // getters so other parts of the app can read the current user
  // they cant set it directly because its private which is intentional
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // the constructor runs once when authprovider is first created
  // it immediately starts listening to firebase auth state changes
  // so the moment someone logs in or out _currentuser updates and notifylisteners fires
  // the authgate that the state mgmt guy is building will react to these changes
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      // firebase calls this every time auth state changes
      // we just store the new user and tell everyone who is listening
      _currentUser = user;
      notifyListeners();
    });
  }

  // sign in with email and password
  // returns a usercredential if it works throws a firebaseauthexception if it doesnt
  // the login screen catches that exception and shows the right error message to the user
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // we rethrow here because the screen should decide what message to show
      // not this class
      rethrow;
    }
  }

  // creates a new firebase auth user then immediately creates a matching firestore document
  // the firestore document lives at users/{uid} and contains the basic user info
  // the data model guy owns the user schema so make sure field names match his appuser model
  Future<UserCredential> registerWithEmail(
      String email,
      String password,
      String displayName,
      ) async {
    try {
      // step 1 create the auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // step 2 create the firestore document for this user
      // we use the uid as the document id so its easy to look up later
      // fields here need to match what the data model guy defines in appuser
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'displayName': displayName,
        'email': email,
        'bio': '',
        'attendingCount': 0,
        'eventsCreated': 0,
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // signs out the current user
  // after this fires authstatechanges emits null
  // which means _currentuser becomes null and notifylisteners fires
  // the authgate will then redirect to the login screen automatically
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // sends a password reset email to the given address
  // the forgot password screen that the state mgmt guy is building will call this
  // note newer firebase versions dont throw user-not-found anymore on purpose
  // so we always show a generic success message on that screen regardless
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // adds the current user uid to the attendeeuids array on the event document
  // uses arrayunion so it wont add duplicates even if called twice
  // the security guy needs to make sure firestore rules allow attendees to update this field
  Future<void> registerForEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'attendeeUids': FieldValue.arrayUnion([_currentUser!.uid]),
    });
  }

  // removes the current user uid from the attendeeuids array on the event document
  // uses arrayremove so it only removes that specific uid and leaves the rest
  Future<void> unregisterFromEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'attendeeUids': FieldValue.arrayRemove([_currentUser!.uid]),
    });
  }
}