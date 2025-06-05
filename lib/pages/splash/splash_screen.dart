import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate after a few seconds
    Timer(const Duration(seconds: 3), () {
      // Navigate to the authentication gate
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF3ACBAB,
      ), // Set background color to match app icon
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Assuming your app icon is named app_icon.png in assets/images/
            Image.asset(
              'assets/images/app_icon.png',
              width: 150, // Adjust size as needed
              height: 150, // Adjust size as needed
            ),
            const SizedBox(height: 24),
            // Optional: Add app name or loading indicator below the icon
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
