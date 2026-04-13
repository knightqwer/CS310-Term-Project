import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationsEnabled = true;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Quiz Invite',
      'body': 'You have been invited to join "Science Quiz".',
      'time': '2m ago',
      'icon': Icons.quiz,
      'read': false,
    },
    {
      'title': 'Quiz Result',
      'body': 'You scored 85% on "History Challenge".',
      'time': '1h ago',
      'icon': Icons.emoji_events,
      'read': false,
    },
    {
      'title': 'Reminder',
      'body': 'Don\'t forget your scheduled quiz at 5:00 PM.',
      'time': '3h ago',
      'icon': Icons.alarm,
      'read': true,
    },
    {
      'title': 'Quiz Invite',
      'body': 'Alex invited you to "Math Blitz".',
      'time': '1d ago',
      'icon': Icons.quiz,
      'read': true,
    },
  ];

  void _clearAll() {
    setState(() => _notifications.clear());
  }

  void _markAsRead(int index) {
    setState(() => _notifications[index]['read'] = true);
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !(n['read'] as bool)).length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Enable toggle
          Container(
            color: const Color(0xFF212121),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (val) =>
                      setState(() => _notificationsEnabled = val),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey.shade600,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.shade800,
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade800, height: 1),

          // Badge row
          if (_notificationsEnabled && _notifications.isNotEmpty && unread > 0)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$unread unread',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ),

          // List or empty state
          Expanded(
            child: !_notificationsEnabled || _notifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final bool isRead = n['read'] as bool;
                      return GestureDetector(
                        onTap: () => _markAsRead(index),
                        child: Opacity(
                          opacity: isRead ? 0.45 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF212121),
                              border: Border(
                                left: BorderSide(
                                  color: isRead
                                      ? Colors.transparent
                                      : Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  n['icon'] as IconData,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n['title'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n['body'] as String,
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  n['time'] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              color: Colors.grey.shade700, size: 64),
          const SizedBox(height: 16),
          Text(
            _notificationsEnabled
                ? 'No notifications yet'
                : 'Notifications are disabled',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
