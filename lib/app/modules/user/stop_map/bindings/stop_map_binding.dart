import 'package:get/get.dart';

import '../controllers/stop_map_controller.dart';

class StopMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StopMapController>(() => StopMapController());
  }
}
