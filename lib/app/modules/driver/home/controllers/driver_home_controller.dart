import 'package:get/get.dart';

import '../../../auth/controllers/auth_controller.dart';

class DriverHomeController extends GetxController {
  Future<void> signOut() => authC.signOut();
}
