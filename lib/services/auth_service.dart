import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  User? get currentUser => null;

  Stream<User?> get authStateChanges => const Stream.empty();

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }

  Future<void> signOut() async {
    return;
  }
}
