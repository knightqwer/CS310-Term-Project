import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: AppStrings.profileNamePlaceholder);
  final emailController = TextEditingController(text: AppStrings.profileEmailPlaceholder);
  final bioController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Display name cannot be empty';
    if (value.trim().length < 2) return 'Display name is too short';
    if (value.trim().length > 32) return 'Display name is too long';
    return null;
  }

  String? _validateBio(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bio cannot be empty';
    if (value.trim().length < 5) return 'Bio must be at least 5 characters';
    if (value.trim().length > 160) return 'Bio must be under 160 characters';
    return null;
  }

  Future<void> handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Profile Saved', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          AppStrings.saveSuccess,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.primary),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: AppColors.error),
      ),
    );
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
        title: Text('Edit Profile', style: AppTextStyles.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth > 600 ? 520.0 : constraints.maxWidth;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPaddings.lg,
                    vertical: AppPaddings.lg,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              Container(
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
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.person,
                                      color: AppColors.textPrimary,
                                      size: 60,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: AppColors.onPrimary,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppPaddings.xl),
                        TextFormField(
                          controller: nameController,
                          validator: _validateName,
                          style: TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration('Full Name'),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        TextFormField(
                          controller: emailController,
                          enabled: false,
                          style: TextStyle(color: AppColors.textHint),
                          decoration: _inputDecoration('Email'),
                        ),
                        const SizedBox(height: AppPaddings.md),
                        TextFormField(
                          controller: bioController,
                          validator: _validateBio,
                          style: TextStyle(color: AppColors.textPrimary),
                          maxLines: 4,
                          decoration: _inputDecoration('Bio'),
                        ),
                        const SizedBox(height: AppPaddings.xl),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: Text('Save Changes', style: AppTextStyles.button),
                          ),
                        ),
                        const SizedBox(height: AppPaddings.md),
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
}
