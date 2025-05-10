import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'login_screen.dart';

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
      backgroundColor: AppColors.dark.primaryColor,
      body: Center(
        child: Text('Cemungut', style: TextStyle(color: Colors.white, fontSize: 32)),
      ),
    );
  }
}
