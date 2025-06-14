import 'package:cemungut_app/presentation/screens/auth/auth_gate.dart';
import 'package:cemungut_app/presentation/screens/auth/login_screen.dart';
import 'package:cemungut_app/presentation/screens/home_screen.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cemungut_app/app/themes/theme.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CemungutApp());
}

class CemungutApp extends StatelessWidget {
  const CemungutApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cemungut',
      theme: AppTheme.light,
      home: AuthGate(),
    );
  }
}
