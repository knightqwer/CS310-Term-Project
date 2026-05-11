import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistering = false;
  bool? _locallyRegistered; // overrides widget.event after user registers

  bool get _isRegistered {
    if (_locallyRegistered != null) return _locallyRegistered!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && widget.event.attendeeUids.contains(uid);
  }

  bool get _isFull => widget.event.attendeeCount >= widget.event.maxAttendees && widget.event.maxAttendees > 0;

  Future<void> _register() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isRegistering = true);
    try {
      final ref = FirebaseFirestore.instance.collection('events').doc(widget.event.id);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = (snap.data()?['attendeeCount'] as int?) ?? 0;
        final uids = List<String>.from(snap.data()?['attendeeUids'] as List? ?? []);
        if (!uids.contains(uid)) {
          uids.add(uid);
          tx.update(ref, {'attendeeUids': uids, 'attendeeCount': current + 1});
        }
      });
      if (mounted) {
        setState(() => _locallyRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final isUpcoming = e.status == 'upcoming';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Event Details', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(AppPaddings.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppPaddings.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: e.imageUrl.isNotEmpty
                                ? Image.network(
                                    e.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(color: AppColors.primary),
                                      );
                                    },
                                    errorBuilder: (_, _, _) => Center(
                                      child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
                                    ),
                                  )
                                : Center(
                                    child: Icon(Icons.event, color: AppColors.textSecondary, size: 48),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isUpcoming ? AppColors.success : AppColors.textSecondary,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isUpcoming ? 'Upcoming' : 'Past',
                            style: TextStyle(
                              color: isUpcoming ? AppColors.success : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        Text(
                          e.title,
                          style: AppTextStyles.headline.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Date & Time',
                          e.dateTime != null
                              ? '${e.date} | ${e.dateTime!.hour.toString().padLeft(2, '0')}:${e.dateTime!.minute.toString().padLeft(2, '0')}'
                              : 'TBD',
                        ),
                        _buildInfoRow(Icons.location_on, 'Location', e.location),
                        _buildInfoRow(Icons.person, 'Organizer', e.organizer),
                        _buildInfoRow(
                          Icons.groups,
                          'Attendees',
                          e.maxAttendees > 0
                              ? '${e.attendeeCount}/${e.maxAttendees} registered'
                              : '${e.attendeeCount} registered',
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text(
                          'About this Event',
                          style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPaddings.sm),
                        Text(
                          e.description.isNotEmpty ? e.description : 'No description provided.',
                          style: AppTextStyles.body.copyWith(height: 1.4),
                        ),
                        if (e.tags.isNotEmpty || e.category.isNotEmpty) ...[
                          const SizedBox(height: AppPaddings.lg),
                          Text(
                            'Associated Tags',
                            style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppPaddings.sm),
                          Wrap(
                            spacing: AppPaddings.sm,
                            runSpacing: AppPaddings.sm,
                            children: [
                              if (e.category.isNotEmpty) _buildTag(e.category),
                              ...e.tags.map(_buildTag),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppPaddings.xl),
                        if (isUpcoming)
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (_isRegistered || _isFull || _isRegistering) ? null : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    disabledBackgroundColor: AppColors.border,
                                    padding: const EdgeInsets.symmetric(vertical: AppPaddings.md),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  ),
                                  child: _isRegistering
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(
                                          _isRegistered
                                              ? 'Registered'
                                              : _isFull
                                                  ? 'Full'
                                                  : 'Register',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppPaddings.sm + 4),
                              Container(
                                decoration: BoxDecoration(color: AppColors.primary),
                                child: IconButton(
                                  icon: Icon(Icons.chat_bubble_outline, color: AppColors.onPrimary),
                                  onPressed: () {
                                    Navigator.pushNamed(context, AppRoutes.eventChat);
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPaddings.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppPaddings.sm + 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
    );
  }
}
