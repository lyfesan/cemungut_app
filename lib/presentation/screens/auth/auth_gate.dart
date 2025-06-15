import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get/get.dart';
import '../../../app/services/firebase_auth_service.dart';
import '../navigation_menu.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show HomePage
        if (snapshot.hasData && snapshot.data != null) {
          // return const HomePage();
          Get.put(NavigationController());
          return NavigationMenu();
        }
        // If user is not logged in, show LoginScreen
        else {
          return const LoginScreen();
        }
      },
    );
  }
}