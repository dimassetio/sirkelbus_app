import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../utils/app_colors.dart';
import '../controllers/driver_scan_controller.dart';

class DriverScanView extends GetView<DriverScanController> {
  const DriverScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Scan Tiket Penumpang',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller.scanner,
            onDetect: controller.onDetect,
          ),
          // Scan frame guide
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.navy, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Processing overlay
          Obx(() {
            if (!controller.isProcessing.value) return const SizedBox.shrink();
            return Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }),
          // Instruction text
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke tiket penumpang',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
