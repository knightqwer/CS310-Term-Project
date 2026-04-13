import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService authService = AuthService(); // getting our helper for auth stuff

  final _nameController = TextEditingController(); // tracker for the name box
  final _emailController = TextEditingController(); // tracker for the email box
  final _passwordController = TextEditingController(); // tracker for the password box
  final _confirmPasswordController = TextEditingController(); // tracker for the second password box
  bool _isLoading = false; // flag to show a spinner when working

  @override
  void dispose() { // cleaning up all controllers to save memory
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) { // checking if any box is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all mandatory fields.')), // showing an alert if empty
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) { // making sure both passwords match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')), // telling user they messed up the match
      );
      return;
    }

    setState(() => _isLoading = true); // start showing the loading spinner

    // Mocked call to our non-crashing service
    await authService.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    ); // pretending to talk to firebase

    if (!mounted) return; // safety check to see if screen still exists

    setState(() => _isLoading = false); // stop the spinner since we are done

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account Mocked Successfully!')), // success message for now
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400], // dark background to contrast the card
      body: Center(
        child: SingleChildScrollView( // adding scroll just in case keyboard pops up
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.grey[300], // lighter card for the inputs
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // taking up only the space we need
              children: [
                const Text(
                  'GatherUp', // our app name
                  style: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'create your account', // little subtitle
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                _buildInputField(_nameController, 'Full Name'), // input box for name
                _buildInputField(_emailController, 'Email'), // input box for email
                _buildInputField(_passwordController, 'Password', obscureText: true), // hidden text for pass
                _buildInputField(_confirmPasswordController, 'Confirm Password', obscureText: true), // hidden text for confirm

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator() // show spinner if we are loading
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleSignUp, // running the logic when clicked
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.black54),),
                    GestureDetector(
                      onTap: () { // moving back to the login page
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

  Widget _buildInputField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller, // connecting the controller here
        obscureText: obscureText, // hiding dots if it is a password
        decoration: InputDecoration(
          labelText: label, // hint text inside the box
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white, // white box for contrast
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none, // no thick border lines
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}