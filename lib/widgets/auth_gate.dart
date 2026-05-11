import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/event_feed_screen.dart';
import '../screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget? child;
  const AuthGate({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    if (!auth.isLoggedIn) return const LoginScreen();
    return child ?? const EventFeedScreen();
  }
}
