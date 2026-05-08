import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';

// this is the event detail screen
// it shows all the info about one event and lets the user register or unregister
// the register and unregister logic goes through authprovider which updates firestore
// the security guy needs to make sure his firestore rules allow attendees to write attendeeuids

class EventDetailScreen extends StatefulWidget {
  // all event data is passed in as constructor params
  // TODO: field names should match the data guy event class
  // whoever navigates to this screen needs to pass all of these in
  final String eventId;
  final String title;
  final String imageUrl;
  final String status;
  final String dateTime;
  final String location;
  final String organizer;
  final int attendeeCount;
  final int maxAttendees;
  final String description;
  final List<String> tags;

  // this is the list of uids of people who registered for the event
  // we check if the current user uid is in here to know if they are registered
  final List<String> attendeeUids;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.imageUrl,
    required this.status,
    required this.dateTime,
    required this.location,
    required this.organizer,
    required this.attendeeCount,
    required this.maxAttendees,
    required this.description,
    required this.tags,
    required this.attendeeUids,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  // _isloading shows a spinner on the button while the firestore update is happening
  bool _isLoading = false;

  // checks if the currently logged in user is already in the attendeeuids list
  // returns false if uid is null which means the user is not logged in
  bool _isRegistered(String? uid) {
    if (uid == null) return false;
    return widget.attendeeUids.contains(uid);
  }

  void _handleRegisterToggle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser?.uid;

    // if there is no uid the user is not logged in somehow
    // this shouldnt happen because the authgate blocks unauthenticated users
    // but just in case we show a message
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to register')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isRegistered(uid)) {
        // user is already registered so we remove their uid using arrayremove
        await authProvider.unregisterFromEvent(widget.eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully unregistered from event')),
          );
        }
      } else {
        // user is not registered so we add their uid using arrayunion
        // arrayunion wont add duplicates so its safe to call multiple times
        await authProvider.registerForEvent(widget.eventId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully registered for event')),
          );
        }
      }
    } catch (e) {
      // something went wrong with the firestore update
      // could be a permissions issue check the security rules
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // we listen true here because we want the button to rebuild
    // when the auth state changes for example if the user logs out while on this screen
    final authProvider = Provider.of<AuthProvider>(context);
    final uid = authProvider.currentUser?.uid;
    final isRegistered = _isRegistered(uid);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
                        // event image loaded from a url
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Image.network(
                              widget.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        // status badge like upcoming or past
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.success),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.status,
                            style: const TextStyle(color: AppColors.success, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        Text(
                          widget.title,
                          style: AppTextStyles.headline.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        // info rows for date location organizer and attendee count
                        _buildInfoRow(Icons.calendar_today, 'Date & Time', widget.dateTime),
                        _buildInfoRow(Icons.location_on, 'Location', widget.location),
                        _buildInfoRow(Icons.person, 'Organizer', widget.organizer),
                        _buildInfoRow(
                          Icons.groups,
                          'Attendees',
                          '${widget.attendeeCount}/${widget.maxAttendees} registered',
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text(
                          'About this Event',
                          style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPaddings.sm),
                        Text(
                          widget.description,
                          style: AppTextStyles.body.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text(
                          'Associated Tags',
                          style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPaddings.sm),
                        // tags come from the event data the data model guy defines these
                        Wrap(
                          spacing: AppPaddings.sm,
                          children: widget.tags.map((tag) => _buildTag(tag)).toList(),
                        ),
                        const SizedBox(height: AppPaddings.xl),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                // button is disabled while loading to prevent double taps
                                onPressed: _isLoading ? null : _handleRegisterToggle,
                                style: ElevatedButton.styleFrom(
                                  // button turns red when the user is already registered
                                  // so it acts as an unregister button visually
                                  backgroundColor: isRegistered ? AppColors.error : AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: AppPaddings.md),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  isRegistered ? 'Unregister' : 'Register',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppPaddings.sm + 4),
                            // chat button goes to the event chat screen
                            // that screen is owned by the real time ui guy
                            // he builds a streambuilder on events/{eventid}/messages
                            Container(
                              decoration: const BoxDecoration(color: AppColors.primary),
                              child: IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onPrimary),
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
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
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
      child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
    );
  }
}