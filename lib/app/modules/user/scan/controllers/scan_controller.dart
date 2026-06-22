import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../data/providers/scan_provider.dart';

class ScanController extends GetxController {
  late final String bookingId;

  final isProcessing = false.obs;
  final MobileScannerController scanner = MobileScannerController();

  @override
  void onInit() {
    super.onInit();
    bookingId = Get.arguments as String? ?? '';
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (isProcessing.value) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    isProcessing(true);
    await scanner.stop();

    final ok = await ScanProvider.instance.checkIn(bookingId, rawValue);
    if (ok) {
      Get.back();
      Get.snackbar(
        'Check-in Berhasil',
        'Selamat datang di bus!',
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
