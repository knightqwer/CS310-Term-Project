import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({super.key});

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  late final Stream<List<Event>> _pastEventsStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _pastEventsStream = FirebaseFirestore.instance
          .collection('events')
          .where('attendeeUids', arrayContains: uid)
          .snapshots()
          .map((snap) {
        final now = DateTime.now();
        final events = snap.docs
            .map((doc) => Event.fromFirestore(doc))
            .where((e) => e.dateTime != null && e.dateTime!.isBefore(now))
            .toList()
          ..sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
        return events;
      });
    } else {
      _pastEventsStream = const Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Event History', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;
          return StreamBuilder<List<Event>>(
            stream: _pastEventsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading events',
                    style: AppTextStyles.body,
                  ),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppPaddings.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: AppPaddings.md),
                        Text('No past events yet', style: AppTextStyles.title),
                        const SizedBox(height: AppPaddings.sm),
                        Text(
                          'Events you attended will appear here',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPaddings.md,
                  vertical: AppPaddings.sm,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: _buildEventCard(events[index]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: AppPaddings.md),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppPaddings.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(Icons.event, color: AppColors.primary),
            ),
            const SizedBox(width: AppPaddings.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppPaddings.xs),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.date,
                          style: AppTextStyles.bodySecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.location,
                          style: AppTextStyles.bodySecondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppPaddings.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppPaddings.sm, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      event.category,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
