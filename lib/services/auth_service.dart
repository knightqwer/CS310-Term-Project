import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // 1. Comment out ALL .instance calls to prevent the [core/no-app] crash
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. Update getters to return null or empty streams so the UI doesn't break
  User? get currentUser => null;

  Stream<User?> get authStateChanges => const Stream.empty();

  // 3. Mocked Sign In
  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  // 4. Mocked Sign Up
  // Changed return type to Future<void> to avoid needing a real UserCredential
  Future<void> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  // 5. Mocked Reset Password
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }

  // 6. Mocked Sign Out
  Future<void> signOut() async {
    return;
  }
}