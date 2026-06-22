import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/booking_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/user_ticket_controller.dart';

class UserTicketView extends GetView<UserTicketController> {
  const UserTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tiket Saya',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.navy),
          );
        }

        if (controller.bookings.isEmpty) {
          return _buildEmpty();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: controller.bookings.length,
          itemBuilder: (_, i) {
            final booking = controller.bookings[i];
            return _TicketCard(
              booking: booking,
              routeName: controller.routeNameFor(booking),
              departureTime: controller.departureTimeFor(booking),
              pickupStop: controller.pickupStopNameFor(booking),
              onTap: () => Get.toNamed(
                Routes.USER_BOOKING_DETAIL,
                arguments: booking.id,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.sectionBackground,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 36,
              color: AppColors.textCaption,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada tiket',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tiket yang kamu pesan akan muncul di sini',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textCaption,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ticket card
// ---------------------------------------------------------------------------

class _TicketCard extends StatelessWidget {
  final BookingModel booking;
  final String routeName;
  final String departureTime;
  final String pickupStop;
  final VoidCallback onTap;

  const _TicketCard({
    required this.booking,
    required this.routeName,
    required this.departureTime,
    required this.pickupStop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = _statusInfo(booking.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    routeName,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: status.fg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.calendar_today_rounded,
                    // label: _formatDate(booking.serviceDate),
                    label: "${booking.serviceDate}",
                  ),
                ),
                Expanded(
                  child: _TicketInfo(
                    icon: Icons.schedule_rounded,
                    label: departureTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _TicketInfo(icon: Icons.location_on_outlined, label: pickupStop),
            const Divider(height: 24),
            Text(
              'Kode Booking: ${booking.id ?? '-'}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textCaption,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TicketInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.navy),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status helpers
// ---------------------------------------------------------------------------

class _StatusInfo {
  final String label;
  final Color fg;
  final Color bg;
  const _StatusInfo(this.label, this.fg, this.bg);
}

_StatusInfo _statusInfo(String? status) {
  switch (status) {
    case BookingStatus.confirmed:
      return const _StatusInfo(
        'Terkonfirmasi',
        AppColors.success,
        Color(0xFFDCFCE7),
      );
    case BookingStatus.pending:
      return const _StatusInfo(
        'Dipesan',
        AppColors.warning,
        Color(0xFFFEF3C7),
      );
    case BookingStatus.cancelled:
      return const _StatusInfo(
        'Dibatalkan',
        AppColors.error,
        Color(0xFFFEE2E2),
      );
    case BookingStatus.completed:
      return const _StatusInfo('Selesai', AppColors.navy, AppColors.navyLight);
    default:
      return _StatusInfo(
        status ?? '-',
        AppColors.textCaption,
        AppColors.sectionBackground,
      );
  }
}

String _formatDate(String? serviceDate) {
  if (serviceDate == null || serviceDate.isEmpty) return '-';
  final date = DateTime.tryParse(serviceDate);
  if (date == null) return serviceDate;
  return DateFormat('EEE, d MMM yyyy', 'id').format(date);
}
