import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_page.dart'; // Import HomePage from the correct path

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;

  const LoginScreen({Key? key, this.prefilledEmail}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // If login is successful, navigate to the main screen
      if (userCredential.user != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        Navigator.pushReplacementNamed(
          context,
          '/home', // Navigate to the /home route
        ); // Navigate to the main screen
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
    }
  }

  void _navigateToSignUp() async {
    final registeredEmail = await Navigator.pushNamed(context, '/signup');
    if (registeredEmail != null && registeredEmail is String) {
      _emailController.text = registeredEmail;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created, please log in.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal, // Match the overall theme color
      body: Stack(
        children: [
          // Top colored section with logo
          Container(
            height:
                MediaQuery.of(context).size.height *
                0.4, // Adjust height as needed
            color: Colors.teal, // Match the top section color from the design
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/app_icon.png', // Assuming this is the logo file
                  width: 80, // Adjust size as needed
                  height: 80, // Adjust size as needed
                  color:
                      Colors.white, // Color the icon white to match the design
                ),
                const SizedBox(height: 8),
                const Text(
                  'FinWise', // Your app name
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Bottom white section with rounded corners and form
          Positioned(
            top:
                MediaQuery.of(context).size.height *
                0.35, // Position the white section
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      'Welcome',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Username Or Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ), // More rounded corners
                          borderSide: BorderSide.none, // Remove border line
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Light grey background
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ), // More rounded corners
                          borderSide: BorderSide.none, // Remove border line
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: Icon(
                          Icons.visibility_off,
                          color: Colors.grey[600],
                        ), // Eye icon
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ), // More rounded corners
                        ),
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ), // Full width button
                      ),
                      onPressed: _login,
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal, // Text color
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(
                          color: Colors.teal,
                        ), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ), // Full width button
                      ),
                      onPressed: _navigateToSignUp,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
