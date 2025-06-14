import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cemungut_app/app/themes/theme.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ));
    });

    return Scaffold(
      backgroundColor: AppTheme.dark.primaryColor,
      body: Center(
        child: Text('Cemungut', style: TextStyle(color: Colors.white, fontSize: 32)),
      ),
    );
  }
}
