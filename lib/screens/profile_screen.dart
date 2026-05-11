import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profile', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final maxWidth = isWide ? 640.0 : constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: AppPaddings.screen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                color: AppColors.textPrimary,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPaddings.md),
                      Text(
                        AppStrings.profileNamePlaceholder,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: AppPaddings.xs),
                      Text(
                        AppStrings.profileEmailPlaceholder,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppPaddings.xs),
                      Text(
                        AppStrings.profileNoBio,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppPaddings.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('0', 'Events\nCreated'),
                          _buildDivider(),
                          _buildStat('0', 'Events\nAttended'),
                          _buildDivider(),
                          _buildStat('-', 'Average\nRating'),
                        ],
                      ),
                      const SizedBox(height: AppPaddings.xl),
                      _buildTile(
                        context,
                        icon: Icons.edit,
                        label: 'Edit Profile',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                      ),
                      const SizedBox(height: AppPaddings.sm + 2),
                      _buildTile(
                        context,
                        icon: Icons.history,
                        label: 'Event History',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.eventHistory),
                      ),
                      const SizedBox(height: AppPaddings.sm + 2),
                      _buildTile(
                        context,
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                      ),
                      const SizedBox(height: AppPaddings.sm + 2),
                      _buildTile(
                        context,
                        icon: Icons.flag_outlined,
                        label: 'Report a Profile',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.reportProfile),
                      ),
                      const SizedBox(height: AppPaddings.sm + 2),
                      _buildTile(
                        context,
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                      const SizedBox(height: AppPaddings.lg),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authService.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPaddings.md),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.stat),
        const SizedBox(height: AppPaddings.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppColors.divider);
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: AppPaddings.tile,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: AppPaddings.sm + 4),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}
