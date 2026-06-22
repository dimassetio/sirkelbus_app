import 'package:get/get.dart';

import '../controllers/user_ticket_controller.dart';

class UserTicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserTicketController>(UserTicketController.new);
  }
}
