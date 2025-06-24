import 'dart:ui';

import 'package:cemungut_app/presentation/screens/auth/auth_gate.dart';
import 'package:cemungut_app/presentation/screens/navigation_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cemungut_app/app/themes/theme.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id_ID', null);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  runApp(ShowCaseWidget(
    builder: (context) => const CemungutApp(),
    globalTooltipActions: [
      TooltipActionButton(
        //backgroundColor: Colors.transparent,
        name: "Kembali",
        type: TooltipDefaultActionType.previous,
        //padding: EdgeInsets.all(8),
        textStyle: TextStyle(color: AppTheme.light.colorScheme.onPrimary),
      ),
      TooltipActionButton(
        //backgroundColor: Colors.transparent,
        name: "Lanjut",
        type: TooltipDefaultActionType.next,
        //padding: EdgeInsets.all(8),
        textStyle: TextStyle(color: AppTheme.light.colorScheme.onPrimary),
      ),
    ],
  ));
}

class CemungutApp extends StatelessWidget {
  const CemungutApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NavigationController());

    // kalau di physical device, pakai
    // return GetMaterialApp (
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Cemungut',
      theme: AppTheme.light,
      home: AuthGate(),
    );
  }
}
