import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
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
  final _userService = UserService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoUrlController = TextEditingController();

  late final String? _uid;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    _photoUrlController.addListener(() => setState(() {}));
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_uid == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Not signed in';
      });
      return;
    }
    try {
      final user = await _userService.getUser(_uid);
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'Profile not found';
        });
        return;
      }
      _nameController.text = user.displayName;
      _emailController.text = user.email;
      _bioController.text = user.bio;
      _photoUrlController.text = user.photoURL;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Could not load profile: $e';
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name cannot be empty';
    }
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

  String? _validatePhotoUrl(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // empty = no avatar, allowed
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Enter a valid http(s) URL';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uid == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final newName = _nameController.text.trim();
      final newPhotoUrl = _photoUrlController.text.trim();
      await _userService.updateUser(_uid, {
        'displayName': newName,
        'bio': _bioController.text.trim(),
        'photoURL': newPhotoUrl,
      });
      final user = FirebaseAuth.instance.currentUser;
      await user?.updateDisplayName(newName);
      await user?.updatePhotoURL(newPhotoUrl.isEmpty ? null : newPhotoUrl);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Profile Saved',
              style: TextStyle(color: AppColors.textPrimary)),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildAvatar(String url) {
    if (url.isEmpty) {
      return Icon(Icons.person, color: AppColors.textPrimary, size: 60);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
      errorBuilder: (_, _, _) => Icon(
        Icons.broken_image,
        color: AppColors.textSecondary,
        size: 40,
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _loadError != null
              ? Center(
                  child: Text(_loadError!, style: AppTextStyles.bodySecondary),
                )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth > 600 ? 520.0 : constraints.maxWidth;
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
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(
                                color: AppColors.border, width: 2),
                          ),
                          child: ClipOval(
                            child: _buildAvatar(_photoUrlController.text.trim()),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPaddings.xl),
                      TextFormField(
                        controller: _nameController,
                        validator: _validateName,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration('Full Name'),
                      ),
                      const SizedBox(height: AppPaddings.md),
                      TextFormField(
                        controller: _emailController,
                        enabled: false,
                        style: TextStyle(color: AppColors.textHint),
                        decoration: _inputDecoration('Email'),
                      ),
                      const SizedBox(height: AppPaddings.md),
                      TextFormField(
                        controller: _bioController,
                        validator: _validateBio,
                        style: TextStyle(color: AppColors.textPrimary),
                        maxLines: 4,
                        decoration: _inputDecoration('Bio'),
                      ),
                      const SizedBox(height: AppPaddings.md),
                      TextFormField(
                        controller: _photoUrlController,
                        validator: _validatePhotoUrl,
                        keyboardType: TextInputType.url,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration('Avatar URL (optional)'),
                      ),
                      const SizedBox(height: AppPaddings.xl),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Text('Save Changes',
                                  style: AppTextStyles.button),
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
    );
  }
}
