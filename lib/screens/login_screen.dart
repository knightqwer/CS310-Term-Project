import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService(); // making a connection to our fake auth logic
  final emailController = TextEditingController(); // capturing what the user types in email
  final passwordController = TextEditingController(); // capturing what the user types in password
  bool obscurePassword = true; // keeping the password hidden by default
  bool isLoading = false; // tracking if we are currently trying to log in

  @override
  void dispose() {
    emailController.dispose(); // cleaning up the email controller to keep memory happy
    passwordController.dispose(); // cleaning up the password controller
    super.dispose();
  }

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) { // checking if user left anything blank
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')), // telling them to fill the boxes
      );
      return;
    }

    setState(() => isLoading = true); // turning on the loading spinner

    try {
      await authService.signIn(
        emailController.text,
        passwordController.text,
      ); // sending the data to our mocked service
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()), // moving to home after success
              (route) => false, // clearing the back history so they cant go back to login
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())), // showing error message if something breaks
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false); // turning off the spinner no matter what happens
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // that dark grey background from the design
      body: Center(
        child: SingleChildScrollView( // making sure it doesnt overflow when keyboard pops up
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0), // a slightly lighter card for the inputs
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // only taking up the space needed for the form
              children: [
                const Text(
                  'GatherUp', // big main branding text
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Log in to your account', // tiny subtitle under the logo
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32), // space before the first input
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email', // hint text inside the box
                    filled: true,
                    fillColor: Colors.white, // white box so it pops
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero), // sharp square corners
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword, // hiding the password characters
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero), // matching the square look
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight, // pushing this to the right side
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(), // jumping to reset password screen
                        ),
                      );
                    },
                    child: const Text(
                      'forgot your password?', // small link text
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const CircularProgressIndicator() // showing the spinner while we wait
                else
                  SizedBox(
                    width: double.infinity, // making the button full width
                    height: 48,
                    child: ElevatedButton(
                      onPressed: handleLogin, // running the login logic on tap
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // keeping the square style
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have any account yet? ", // prompting the user to sign up
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()), // going to the sign up page
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.black,
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
    );
  }
}