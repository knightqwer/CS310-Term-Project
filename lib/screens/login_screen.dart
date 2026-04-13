import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await authService.signIn(
        emailController.text,
        passwordController.text,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppPaddings.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 480 : double.infinity),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppPaddings.xl, vertical: AppPaddings.xl + AppPaddings.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 64,
                      height: 64,
                      errorBuilder: (_, _, _) => const Icon(Icons.event, size: 64, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    Text(AppStrings.appName, style: AppTextStyles.headline),
                    Text(AppStrings.loginSubtitle, style: AppTextStyles.subtitle),
                    const SizedBox(height: AppPaddings.xl),
                    TextField(
                      controller: emailController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.background,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.background,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: Text(
                          'forgot your password?',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          child: Text('Login', style: AppTextStyles.button),
                        ),
                      ),
                    const SizedBox(height: AppPaddings.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have any account yet? ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.signup);
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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
    );
  }
}
