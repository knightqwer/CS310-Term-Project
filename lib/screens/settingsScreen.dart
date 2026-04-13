import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/authService.dart';
import 'loginScreen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _quizInvites = true;
  bool _quizResults = true;
  bool _reminders = false;

  Future<void> _signOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // --- Account Info ---
          _sectionHeader('ACCOUNT'),
          Container(
            color: const Color(0xFF212121),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                child: Text(
                  displayName.isNotEmpty
                      ? displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                displayName,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                email,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
          ),
          Divider(color: Colors.grey.shade800, height: 1),

          const SizedBox(height: 20),

          // --- Notification Preferences ---
          _sectionHeader('NOTIFICATIONS'),
          Container(
            color: const Color(0xFF212121),
            child: Column(
              children: [
                _switchTile(
                  title: 'Quiz Invites',
                  subtitle: 'Get notified when someone invites you to a quiz',
                  value: _quizInvites,
                  onChanged: (v) => setState(() => _quizInvites = v),
                  isFirst: true,
                ),
                Divider(
                    color: Colors.grey.shade800, height: 1, indent: 16),
                _switchTile(
                  title: 'Quiz Results',
                  subtitle: 'Receive your quiz result summaries',
                  value: _quizResults,
                  onChanged: (v) => setState(() => _quizResults = v),
                ),
                Divider(
                    color: Colors.grey.shade800, height: 1, indent: 16),
                _switchTile(
                  title: 'Reminders',
                  subtitle: 'Reminders for scheduled quizzes',
                  value: _reminders,
                  onChanged: (v) => setState(() => _reminders = v),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade800, height: 1),

          const SizedBox(height: 32),

          // --- Sign Out ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _signOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isFirst = false,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.grey.shade600,
      inactiveThumbColor: Colors.grey,
      inactiveTrackColor: Colors.grey.shade800,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
    );
  }
}
