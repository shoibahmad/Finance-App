// lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:managment/screens/auth_wrapper.dart'; // Your AuthWrapper path

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Wait for a few seconds (e.g., 3 seconds) then navigate
    Timer(const Duration(seconds: 3), () {
      // Ensure the widget is still mounted before navigating
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the primary color from the theme for consistency
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor, // Set background to the theme's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Your App Icon (replace with your actual app icon if you have one)
            Icon(
              Icons.account_balance_wallet_outlined, // Example icon
              size: 100.0,
              color: Colors.white, // White icon contrasts well with teal
            ),
            const SizedBox(height: 20.0),
             Text(
              'Finance Manager', // Optional: App Name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50.0),
            // SpinKit Loading Indicator
            SpinKitFadingCircle( // Choose any SpinKit animation you like
              color: Colors.white, // White spinner
              size: 50.0,
            ),
             const SizedBox(height: 20.0),
             Text(
              'Loading...', // Optional: Loading text
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}