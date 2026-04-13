import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_text_styles.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Image.network(
                              'https://freesvg.org/img/1460481845.png',
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                );
                              },
                              errorBuilder: (_, _, _) => Center(
                                child: Icon(Icons.broken_image, color: AppColors.textSecondary, size: 40),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.success),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Upcoming',
                            style: TextStyle(color: AppColors.success, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        Text(
                          'Study Session',
                          style: AppTextStyles.headline.copyWith(fontSize: 28),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        _buildInfoRow(Icons.calendar_today, 'Date & Time', 'Apr 12, 2026 | 14:00'),
                        _buildInfoRow(Icons.location_on, 'Location', 'Information Center, Room 204'),
                        _buildInfoRow(Icons.person, 'Organizer', 'Name Surname'),
                        _buildInfoRow(Icons.groups, 'Attendees', '8/20 registered'),
                        const SizedBox(height: AppPaddings.lg),
                        Text(
                          'About this Event',
                          style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPaddings.sm),
                        Text(
                          'This text includes whatever the organizer wrote in the bio part. '
                          '"Come join us for this event" - "I need some help prepping for an exam" '
                          '- "I want some company/meet new people"',
                          style: AppTextStyles.body.copyWith(height: 1.4),
                        ),
                        const SizedBox(height: AppPaddings.lg),
                        Text(
                          'Associated Tags',
                          style: AppTextStyles.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppPaddings.sm),
                        Wrap(
                          spacing: AppPaddings.sm,
                          children: [
                            _buildTag('Social'),
                            _buildTag('Other'),
                            _buildTag('Study'),
                            _buildTag('Sports'),
                          ],
                        ),
                        const SizedBox(height: AppPaddings.xl),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: AppPaddings.md),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: AppPaddings.sm + 4),
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
