import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_service.dart';
import 'username_setup_screen.dart';
import 'splash_screen.dart';
import 'auth_login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<Map<String, dynamic>?>(
            future: AuthService().getUserData(),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              final userData = userDataSnapshot.data;
              
              // Check if user has set up username
              if (userData != null && 
                  (userData['username'] == null || userData['username'].toString().isEmpty)) {
                return const UsernameSetupScreen();
              }
              
              // User is fully set up, show main app
              return const SplashScreen(skipToGame: true);
            },
          );
        }
          // User is not signed in
        return const AuthLoginScreen();
      },
    );
  }
}
