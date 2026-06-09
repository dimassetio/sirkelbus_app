import 'package:get/get.dart';

import '../../../auth/controllers/auth_controller.dart';

class UserHomeController extends GetxController {
  Future<void> signOut() => authC.signOut();
}
