import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_routes.dart';

/// Sits at the root of the widget tree.
/// Listens to FirebaseAuth.authStateChanges() and routes accordingly:
///   - logged out  →  Login screen
///   - logged in   →  Home (Event Feed) screen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for the first auth event
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is logged in → go to Home
        if (snapshot.hasData && snapshot.data != null) {
          return Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) {
                // Defer to the named route system
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.home);
                });
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          );
        }

        // User is logged out → go to Login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.settings.name != AppRoutes.login) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        });

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
