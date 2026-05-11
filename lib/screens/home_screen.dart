import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) => Icon(Icons.event, size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: AppPaddings.sm),
            Text(AppStrings.appName, style: AppTextStyles.title),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              padding: AppPaddings.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppPaddings.lg),
                  Text('Event Feed', style: AppTextStyles.headline),
                  const SizedBox(height: AppPaddings.sm),
                  Text(
                    'Browse, search, and discover campus events.',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: AppPaddings.lg),
                  _buildQuickActions(context, isWide),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _HomeBottomNav(currentIndex: 0),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isWide) {
    final items = [
      _QuickAction(icon: Icons.calendar_today, label: 'My Events', route: AppRoutes.myEvents),
      _QuickAction(icon: Icons.add_circle_outline, label: 'Create Event', route: AppRoutes.createEvent),
      _QuickAction(icon: Icons.person, label: 'Profile', route: AppRoutes.profile),
      _QuickAction(icon: Icons.notifications_outlined, label: 'Notifications', route: AppRoutes.notifications),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppPaddings.md,
      crossAxisSpacing: AppPaddings.md,
      childAspectRatio: 1.6,
      children: items
          .map((a) => _buildActionTile(context, a))
          .toList(),
    );
  }

  Widget _buildActionTile(BuildContext context, _QuickAction action) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Container(
        padding: const EdgeInsets.all(AppPaddings.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: AppColors.textPrimary, size: 28),
            const SizedBox(height: AppPaddings.sm),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;
  const _QuickAction({required this.icon, required this.label, required this.route});
}

class _HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  const _HomeBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
            break;
          case 1:
            Navigator.pushNamed(context, AppRoutes.myEvents);
            break;
          case 2:
            Navigator.pushNamed(context, AppRoutes.createEvent);
            break;
          case 3:
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Events'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Create'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
