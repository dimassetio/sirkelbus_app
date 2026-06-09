import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.lazyPut<AuthController>(AuthController.new, fenix: true);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SirkelBus',
      defaultTransition: Transition.cupertino,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: AppTheme.light,
    ),
  );
}
