import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:managment/screens/login_screen.dart';
import 'package:managment/widgets/bottomnavigationbar.dart'; // Your existing Bottom widget

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User is logged in
          return const Bottom(); // Navigate to your main app screen
        } else {
          // User is not logged in
          return const LoginScreen(); // Navigate to Login Screen
        }
      },
    );
  }
}