import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_item.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.title),
      ),
      body: uid == null ? _emptyState() : _stream(uid),
    );
  }

  Widget _stream(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Failed to load notifications', style: AppTextStyles.bodySecondary),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _emptyState();

        final items = docs.map(NotificationItem.fromFirestore).toList();
        return ListView.separated(
          padding: const EdgeInsets.all(AppPaddings.md),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppPaddings.sm),
          itemBuilder: (_, i) => _tile(items[i]),
        );
      },
    );
  }

  Widget _tile(NotificationItem item) {
    final timeLabel = item.createdAt != null
        ? DateFormat('MMM d, h:mm a').format(item.createdAt!)
        : '';

    return Container(
      padding: AppPaddings.tile,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.read ? Icons.notifications_none : Icons.notifications,
            color: item.read ? AppColors.textSecondary : AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: AppPaddings.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.body),
                if (item.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.body, style: AppTextStyles.bodySecondary),
                ],
                if (timeLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(timeLabel, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
          if (!item.read)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppPaddings.md),
            Text('No notifications yet', style: AppTextStyles.title),
            const SizedBox(height: AppPaddings.sm),
            Text(
              "You'll be notified about event updates here",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      ),
    );
  }
}
