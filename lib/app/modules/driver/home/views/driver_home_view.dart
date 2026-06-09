import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/driver_home_controller.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.32;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        children: [
          _buildHero(heroHeight),
          Positioned(
            top: heroHeight - 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.pageBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hari Ini',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEmptyTripCard(),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: controller.signOut,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Keluar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(double heroHeight) {
    return Container(
      width: double.infinity,
      height: heroHeight,
      color: AppColors.navy900,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel Driver',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Halo, ${authC.user.name ?? 'Driver'} 👋',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  _OnlineBadge(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.drive_eta_outlined, size: 32, color: AppColors.navy),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada trip',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trip hari ini akan muncul di sini',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textCaption),
          ),
        ],
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Online',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
