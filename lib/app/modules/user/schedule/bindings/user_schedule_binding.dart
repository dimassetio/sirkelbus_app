import 'package:get/get.dart';

import '../controllers/user_schedule_controller.dart';

class UserScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserScheduleController>(UserScheduleController.new);
  }
}
