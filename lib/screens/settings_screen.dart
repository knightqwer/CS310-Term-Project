import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool locationSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTextStyles.title),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Preferences'),
                      _buildToggleTile(
                        label: 'Push Notifications',
                        value: pushNotifications,
                        onChanged: (v) => setState(() => pushNotifications = v),
                      ),
                      _buildToggleTile(
                        label: 'Dark Mode',
                        value: context.watch<ThemeProvider>().isDarkMode,
                        onChanged: (v) => context.read<ThemeProvider>().setDarkMode(v),
                      ),
                      _buildToggleTile(
                        label: 'Location Sharing',
                        value: locationSharing,
                        onChanged: (v) => setState(() => locationSharing = v),
                      ),
                      const SizedBox(height: AppPaddings.lg),
                      _buildSectionHeader('Account'),
                      _buildNavTile(icon: Icons.lock_outline, label: 'Change Password'),
                      _buildNavTile(icon: Icons.shield_outlined, label: 'Privacy Policy'),
                      _buildNavTile(icon: Icons.description_outlined, label: 'Terms of Service'),
                      const SizedBox(height: AppPaddings.lg),
                      _buildSectionHeader('About'),
                      Container(
                        padding: AppPaddings.tile,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.textPrimary, size: 20),
                            const SizedBox(width: AppPaddings.sm + 4),
                            Expanded(child: Text('App Version', style: AppTextStyles.body)),
                            Text('v1.0.0', style: AppTextStyles.bodySecondary),
                          ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPaddings.sm),
      child: Text(title, style: AppTextStyles.bodySecondary),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppPaddings.sm),
      padding: AppPaddings.tile,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({required IconData icon, required String label}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppPaddings.sm),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label coming soon')),
          );
        },
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
      ),
    );
  }
}
