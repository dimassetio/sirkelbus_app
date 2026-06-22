import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/data/services/api_client.dart';
import 'app/data/services/notification_service.dart';
import 'app/data/services/remote_config_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await initializeDateFormatting('id');
  await RemoteConfigService.instance.init();
  ApiClient.instance.init();
  await NotificationService.instance.initialize();

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
