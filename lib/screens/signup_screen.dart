import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_paddings.dart';
import '../utils/app_routes.dart';
import '../utils/app_strings.dart';
import '../utils/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// this is the signup screen
// it handles user registration and also creates the firestore user document
// the data model guy owns the appuser schema so field names here need to match his model

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // formkey lets us validate all fields at once before calling firebase
  final _formKey = GlobalKey<FormState>();

  // one controller per field
  // _namecontroller is what gets passed to authprovider as the displayname
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // _errormessage shows firebase errors that slip past local validation
  // like email already in use which we cant check locally
  String? _errorMessage;
  bool _isLoading = false;

  void _handleSignUp() async {
    // run form validation first before touching firebase
    // if any field fails its validator we stop here and show the inline errors
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // authprovider.registerwithemailcreates the auth user
      // and then immediately writes the users/{uid} firestore document
      // fields in that document need to match what the data model guy defines in appuser
      await Provider.of<AuthProvider>(context, listen: false)
          .registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
      // authgate handles navigation automatically after registration
    } on FirebaseAuthException catch (e) {
      // these are errors that come back from firebase after we tried to register
      // local validation already caught empty fields and short passwords
      // so these are edge cases like duplicate email
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = 'This email is already registered';
            break;
          case 'weak-password':
            _errorMessage = 'Password must be at least 6 characters';
            break;
          case 'invalid-email':
            _errorMessage = 'Please enter a valid email';
            break;
          default:
            _errorMessage = e.message ?? 'An error occurred';
        }
      });
    } finally {
      // always turn off the spinner regardless of what happened
      setState(() => _isLoading = false);
    }
  }

  // dispose all controllers to free memory when this screen is removed
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // validator functions for each field
  // these run when the user interacts with the form because of autovalidatemode

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

  // confirm password just checks it matches the password field
  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
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
                  // validates fields as the user types so errors show up in real time
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
                      // show firebase error message if there is one
                      // local validation errors show inline under each field
                      // this catches anything that slips through like duplicate email
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppPaddings.sm),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  // reusable field builder so we dont repeat the same decoration code for every field
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