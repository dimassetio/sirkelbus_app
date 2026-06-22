import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../data/providers/driver_check_in_provider.dart';

class DriverScanController extends GetxController {
  late final String tripId;

  final isProcessing = false.obs;
  final MobileScannerController scanner = MobileScannerController();

  @override
  void onInit() {
    super.onInit();
    tripId = Get.arguments as String? ?? '';
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    isProcessing(true);
    await scanner.stop();

    final ok = await DriverCheckInProvider.instance.checkIn(tripId, rawValue);
    if (ok) {
      Get.back();
      Get.snackbar(
        'Check-in Berhasil',
        'Penumpang berhasil naik.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      await scanner.start();
      isProcessing(false);
    }
  }

  @override
  void onClose() {
    scanner.dispose();
    super.onClose();
  }
}
