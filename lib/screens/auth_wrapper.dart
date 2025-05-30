import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auth_service.dart';
import 'username_setup_screen.dart';
import 'splash_screen.dart';
import 'auth_login_screen.dart';
import 'home_page.dart';

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
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
            stream: AuthService().getUserDataStream(),
            builder: (context, userDataSnapshot) {
              if (userDataSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              final userDoc = userDataSnapshot.data;
              final userData = userDoc?.data();
              
              // Check if user has set up username
              if (userData == null || 
                  userData['username'] == null || 
                  userData['username'].toString().isEmpty) {
                return const UsernameSetupScreen();
              }
              
              // User is fully set up, show home page
              return const HomePage();
            },
          );
        }
        
        // User is not signed in
        return const AuthLoginScreen();
      },
    );
  }
}
