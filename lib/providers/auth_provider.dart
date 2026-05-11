import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;
  User? _user;

  AuthProvider({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _user = _auth.currentUser;
    _sub = _auth.authStateChanges().listen(_onAuthChange);
  }

  User? get currentUser => _user;
  bool get isLoggedIn => _user != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _onAuthChange(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return mapAuthError(e.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak — use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
