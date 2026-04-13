import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await authService.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Account Created', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Welcome to ${AppStrings.appName}, ${_nameController.text.trim()}!',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
            },
            child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppPaddings.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 480 : double.infinity),
              child: Container(
                padding: const EdgeInsets.all(AppPaddings.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.appName, style: AppTextStyles.headline),
                      Text(AppStrings.signupSubtitle, style: AppTextStyles.subtitle),
                      const SizedBox(height: AppPaddings.lg),
                      _buildField(_nameController, 'Full Name', validator: _validateName),
                      _buildField(_emailController, 'Email', validator: _validateEmail),
                      _buildField(_passwordController, 'Password', obscureText: true, validator: _validatePassword),
                      _buildField(_confirmPasswordController, 'Confirm Password', obscureText: true, validator: _validateConfirm),
                      const SizedBox(height: AppPaddings.md),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                child: Text('Sign Up', style: AppTextStyles.button),
                              ),
                            ),
                      const SizedBox(height: AppPaddings.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Log in',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppPaddings.sm),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.background,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppPaddings.md, vertical: 12),
        ),
      ),
    );
  }
}
