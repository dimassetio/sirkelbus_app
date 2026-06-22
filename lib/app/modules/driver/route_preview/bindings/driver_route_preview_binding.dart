import 'package:get/get.dart';

import '../controllers/driver_route_preview_controller.dart';

class DriverRoutePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverRoutePreviewController>(
        DriverRoutePreviewController.new);
  }
}
