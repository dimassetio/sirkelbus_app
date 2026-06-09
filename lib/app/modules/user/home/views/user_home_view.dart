import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/user_home_controller.dart';

class UserHomeView extends GetView<UserHomeController> {
  const UserHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.35;

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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchCard(),
                    const SizedBox(height: 32),
                    Text(
                      'Menu Utama',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      icon: Icons.directions_bus_rounded,
                      title: 'Jadwal Bus',
                      subtitle: 'Lihat semua jadwal perjalanan',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Tiket Saya',
                      subtitle: 'Lihat riwayat pemesanan',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      icon: Icons.location_on_outlined,
                      title: 'Lacak Perjalanan',
                      subtitle: 'Pantau posisi bus secara real-time',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHero(double heroHeight) {
    return Container(
      width: double.infinity,
      height: heroHeight,
      color: AppColors.navy,
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
                        'Halo, ${authC.user.name ?? 'Penumpang'} 👋',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Colors.white60),
                          const SizedBox(width: 3),
                          Text(
                            'Indonesia',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _HeaderActionButton(
                    icon: Icons.notifications_outlined,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cari Perjalanan',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const _SearchRow(
            icon: Icons.radio_button_unchecked_rounded,
            label: 'Kota asal',
            hint: 'Pilih kota asal',
          ),
          const Divider(height: 1, indent: 30),
          const _SearchRow(
            icon: Icons.location_on_outlined,
            label: 'Tujuan',
            hint: 'Pilih kota tujuan',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Cari Bus'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.navy, size: 22),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textCaption),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textCaption),
          ],
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Beranda', isActive: true),
          _NavItem(icon: Icons.search_rounded, label: 'Cari', isActive: false),
          _NavItem(icon: Icons.confirmation_number_outlined, label: 'Tiket', isActive: false),
          _NavItem(icon: Icons.person_outline_rounded, label: 'Profil', isActive: false),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  const _SearchRow({required this.icon, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textCaption),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  const _NavItem({required this.icon, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.navy : const Color(0xFF94A3B8);
    return Column(
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
    );
  }
}
