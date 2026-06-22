import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/booking_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/user_home_controller.dart';

class UserHomeView extends GetView<UserHomeController> {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SizedBox.expand(
        child: Stack(
          children: [
            _buildHero(heroHeight),
            Positioned(
              top: heroHeight - 24,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.pageBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TodayBookingCard(controller: controller),
                      const SizedBox(height: 28),
                      Text(
                        'Mulai Perjalanan',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DirectionShortcuts(),
                      const SizedBox(height: 28),
                      Text(
                        'Menu',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MenuTile(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Tiket Saya',
                        subtitle: 'Lihat riwayat & status pemesanan',
                        onTap: () => Get.toNamed(Routes.USER_TICKET),
                      ),
                      const SizedBox(height: 10),
                      _MenuTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Profil Saya',
                        subtitle: 'Kelola data akun dan preferensi',
                        onTap: () => Get.toNamed(Routes.USER_PROFILE),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHero(double heroHeight) {
    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14213D), Color(0xFF1E3A5F)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: SafeArea(
        bottom: false,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE, d MMMM', 'id').format(DateTime.now()),
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
              const SizedBox(height: 6),
              Text(
                'Halo, ${authC.user.name?.split(' ').first ?? 'Penumpang'} 👋',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mau ke mana hari ini?',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _NavItem(
            icon: Icons.home_rounded,
            label: 'Beranda',
            isActive: true,
          ),
          _NavItem(
            icon: Icons.directions_bus_rounded,
            label: 'Jadwal',
            isActive: false,
            onTap: () => Get.toNamed(Routes.USER_SCHEDULE),
          ),
          _NavItem(
            icon: Icons.confirmation_number_outlined,
            label: 'Tiket',
            isActive: false,
            onTap: () => Get.toNamed(Routes.USER_TICKET),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            isActive: false,
            onTap: () => Get.toNamed(Routes.USER_PROFILE),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Today's booking card
// ---------------------------------------------------------------------------

class _TodayBookingCard extends StatelessWidget {
  final UserHomeController controller;
  const _TodayBookingCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final booking = controller.topBooking;
      if (booking == null) return const SizedBox.shrink();

      final statusInfo = _statusOf(booking);

      return GestureDetector(
        onTap: () =>
            Get.toNamed(Routes.USER_BOOKING_DETAIL, arguments: booking.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF14213D), Color(0xFF1E3A5F)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14213D).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Booking Hari Ini',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusInfo.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      statusInfo.icon,
                      color: statusInfo.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusInfo.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'ID: ${booking.id?.substring(0, 12) ?? '-'}...',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white38,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _BookingStatusInfo {
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  const _BookingStatusInfo(this.label, this.description, this.color, this.icon);
}

_BookingStatusInfo _statusOf(BookingModel b) {
  if (b.isBoarded) {
    return const _BookingStatusInfo(
      'Di Dalam Bus',
      'Kamu sedang dalam perjalanan',
      Color(0xFF60A5FA),
      Icons.directions_bus_rounded,
    );
  }
  switch (b.status) {
    case BookingStatus.confirmed:
      return const _BookingStatusInfo(
        'Terkonfirmasi',
        'Tiket siap, tunggu keberangkatan',
        Color(0xFF4ADE80),
        Icons.check_circle_rounded,
      );
    case BookingStatus.pending:
      return const _BookingStatusInfo(
        'Dipesan',
        'Menunggu driver memulai perjalanan',
        Color(0xFFFBBF24),
        Icons.hourglass_top_rounded,
      );
    case BookingStatus.completed:
      return const _BookingStatusInfo(
        'Selesai',
        'Perjalanan hari ini selesai',
        Color(0xFF94A3B8),
        Icons.flag_rounded,
      );
    default:
      return const _BookingStatusInfo(
        'Aktif',
        'Kamu memiliki booking hari ini',
        Color(0xFF4ADE80),
        Icons.confirmation_number_rounded,
      );
  }
}

// ---------------------------------------------------------------------------
// Direction shortcut cards
// ---------------------------------------------------------------------------

class _DirectionShortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _DirectionCard(
            icon: Icons.school_rounded,
            label: 'Pergi ke\nSekolah',
            color: AppColors.navy,
            onTap: () => Get.toNamed(Routes.USER_SCHEDULE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _DirectionCard(
            icon: Icons.home_rounded,
            label: 'Pulang dari\nSekolah',
            color: const Color(0xFF0F766E),
            onTap: () =>
                Get.toNamed(Routes.USER_SCHEDULE, arguments: 'fromSchool'),
          ),
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DirectionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Lihat jadwal',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded, size: 11, color: color),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Menu tile
// ---------------------------------------------------------------------------

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textCaption,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.textCaption,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom nav
// ---------------------------------------------------------------------------

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.navy : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
