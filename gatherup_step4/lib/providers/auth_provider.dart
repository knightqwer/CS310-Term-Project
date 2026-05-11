import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Called from ForgotPasswordScreen
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    } catch (_) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out — called from Profile screen
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
