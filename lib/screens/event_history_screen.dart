import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Event History', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
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
            ),
          );
        },
      ),
    );
  }
}
