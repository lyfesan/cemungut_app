import 'package:cemungut_app/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart';

void main() {
  runApp(const CemungutApp());
}

class CemungutApp extends StatelessWidget {
  const CemungutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cemungut',
      theme: AppColors.light,
      home: const SplashScreen(), // Buat dulu dummy page
    );
  }
}
