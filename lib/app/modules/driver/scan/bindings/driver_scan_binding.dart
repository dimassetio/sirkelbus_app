import 'package:get/get.dart';

import '../controllers/driver_scan_controller.dart';

class DriverScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverScanController>(() => DriverScanController());
  }
}
