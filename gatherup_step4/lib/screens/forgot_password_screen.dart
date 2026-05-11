import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_dimens.dart';
import '../utils/app_routes.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      // Show inline error under the form
      setState(() => _errorMessage = error);
    } else {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLG),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 28),
            const SizedBox(width: AppDimens.paddingSM),
            Text('Email Sent', style: AppTextStyles.titleLarge),
          ],
        ),
        content: Text(
          'A password reset link has been sent to\n'
          '${_emailController.text.trim()}.\n'
          'Please check your inbox.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .pushReplacementNamed(AppRoutes.login);
            },
            child: Text('Back to Login', style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: AppDimens.iconMD),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal:
                  isWide ? screenWidth * 0.2 : AppDimens.paddingLG,
              vertical: AppDimens.paddingMD,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: AppDimens.paddingXL),
                _buildFormCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLG),
          child: Image.network(
            'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=80&h=80&fit=crop',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppDimens.radiusLG),
              ),
              child: const Icon(Icons.lock_reset,
                  color: AppColors.primary, size: 36),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingMD),
        Text('GatherUp', style: AppTextStyles.displayLarge),
        const SizedBox(height: AppDimens.paddingXS),
        Text('Reset your password',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildFormCard() {
    return Card(
      color: AppColors.surface,
      elevation: AppDimens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLG),
      ),
      child: Padding(
        padding: AppDimens.cardPadding
            .add(const EdgeInsets.symmetric(vertical: AppDimens.paddingMD)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Enter your registered email and we'll send you a "
                'link to reset your password.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.paddingLG),

              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(val.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              // Firebase error message shown inline
              if (_errorMessage != null) ...[
                const SizedBox(height: AppDimens.paddingSM),
                Text(_errorMessage!, style: AppTextStyles.error),
              ],

              const SizedBox(height: AppDimens.paddingXL),

              AppButton(
                label: 'Send Reset Link',
                isLoading: _isLoading,
                onPressed: _handleSendResetLink,
              ),

              const SizedBox(height: AppDimens.paddingMD),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.login),
                  child: Text('Back to Log In', style: AppTextStyles.link),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
