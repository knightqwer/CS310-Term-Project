import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// this is the login screen
// it only handles ui and calls authprovider for the actual firebase work
// no firebase calls happen directly here everything goes through authprovider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // controllers to read what the user typed in the fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // _errormessage holds whatever error firebase gave us so we can show it in the ui
  String? _errorMessage;

  // obscurepassword toggles whether the password field shows dots or plain text
  bool obscurePassword = true;

  // _isloading shows a spinner while firebase is doing its thing
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // we grab authprovider from the multiprovider tree
      // listen false because we dont need this widget to rebuild when authprovider changes
      // the authgate handles navigation so we dont push any routes here
      await Provider.of<AuthProvider>(context, listen: false)
          .signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // authgate handles navigation automatically after login
    } on FirebaseAuthException catch (e) {
      // map firebase error codes to friendly messages for the user
      setState(() {
        switch (e.code) {
          case 'invalid-credential':
          // newer firebase merges wrong-password and user-not-found into this
          // which is good because it prevents email enumeration
            _errorMessage = 'Invalid email or password';
            break;
          case 'user-disabled':
            _errorMessage = 'This account has been disabled';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many attempts, try again later';
            break;
          default:
            _errorMessage = e.message ?? 'An error occurred';
        }
      });
    } finally {
      // always stop the loading spinner whether it worked or not
      setState(() => _isLoading = false);
    }
  }

  // always dispose controllers when the widget is removed to avoid memory leaks
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.event, size: 64, color: AppColors.primary),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    Text(AppStrings.appName, style: AppTextStyles.headline),
                    Text(AppStrings.loginSubtitle, style: AppTextStyles.subtitle),
                    const SizedBox(height: AppPaddings.xl),
                    TextField(
                      controller: _emailController,
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
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.background,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                        // toggle button to show or hide the password
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // this goes to the forgot password screen
                          // that screen is owned by the state mgmt guy
                          // it will call authprovider.sendpasswordresetemail
                          Navigator.pushNamed(context, AppRoutes.forgotPassword);
                        },
                        child: Text(
                          'forgot your password?',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPaddings.md),
                    // show error message if there is one
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppPaddings.sm),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
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