import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../data/models/booking_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/booking_detail_controller.dart';

class BookingDetailView extends GetView<BookingDetailController> {
  const BookingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail Tiket',
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

        final booking = controller.booking.value;
        if (booking == null) {
          return Center(
            child: Text(
              'Tiket tidak ditemukan.',
              style: GoogleFonts.inter(color: AppColors.textCaption),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusBanner(booking: booking),
              const SizedBox(height: 16),
              _StatusTimeline(booking: booking),
              Obx(() {
                if (controller.trip.value == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _BusTrackingCard(controller: controller),
                  ],
                );
              }),
              const SizedBox(height: 16),
              _BookingInfoCard(
                booking: booking,
                routeName: controller.routeName,
                routeDirection: controller.routeDirection,
                departureTime: controller.departureTime,
                pickupStopName: controller.pickupStopName,
              ),
              const SizedBox(height: 16),
              _ShowQrCodeButton(bookingId: booking.id ?? '-'),
              const SizedBox(height: 24),
              _ActionArea(controller: controller, booking: booking),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Status banner
// ---------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  final BookingModel booking;
  const _StatusBanner({required this.booking});

  @override
  Widget build(BuildContext context) {
    final info = _statusInfo(booking.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: info.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(info.icon, color: info.fg, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: info.fg,
                  ),
                ),
                Text(
                  info.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: info.fg.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status timeline
// ---------------------------------------------------------------------------

class _StatusTimeline extends StatelessWidget {
  final BookingModel booking;
  const _StatusTimeline({required this.booking});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        label: 'Dipesan',
        icon: Icons.confirmation_number_outlined,
        done: true,
      ),
      _TimelineStep(
        label: 'Terkonfirmasi',
        icon: Icons.check_circle_outline_rounded,
        done: booking.status == BookingStatus.confirmed ||
            booking.isBoarded ||
            booking.isCompleted,
      ),
      _TimelineStep(
        label: 'Naik Bus',
        icon: Icons.directions_bus_rounded,
        done: booking.isBoarded || booking.isCompleted,
      ),
      _TimelineStep(
        label: 'Selesai',
        icon: Icons.flag_outlined,
        done: booking.isCompleted,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(child: _TimelineDot(step: steps[i])),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  color: steps[i + 1].done ? AppColors.navy : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String label;
  final IconData icon;
  final bool done;
  const _TimelineStep(
      {required this.label, required this.icon, required this.done});
}

class _TimelineDot extends StatelessWidget {
  final _TimelineStep step;
  const _TimelineDot({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: step.done ? AppColors.navy : AppColors.sectionBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            step.icon,
            size: 16,
            color: step.done ? Colors.white : AppColors.textCaption,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: step.done ? FontWeight.w600 : FontWeight.w400,
            color: step.done ? AppColors.navy : AppColors.textCaption,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Booking info card
// ---------------------------------------------------------------------------

class _BookingInfoCard extends StatelessWidget {
  final BookingModel booking;
  final String routeName;
  final String routeDirection;
  final String departureTime;
  final String pickupStopName;

  const _BookingInfoCard({
    required this.booking,
    required this.routeName,
    required this.routeDirection,
    required this.departureTime,
    required this.pickupStopName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.directions_bus_rounded,
            label: 'Rute',
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (routeDirection.isNotEmpty)
                  Text(
                    routeDirection,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textCaption),
                  ),
              ],
            ),
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: Text(
              _formatDate(booking.serviceDate),
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Keberangkatan',
            value: Text(
              departureTime,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          const Divider(height: 24),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Titik naik',
            value: Text(
              pickupStopName,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          if (booking.boardedAt != null && booking.boardedAt!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.login_rounded,
              label: 'Waktu naik',
              value: Text(
                _formatDateTime(booking.boardedAt),
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.navy),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: AppColors.textCaption),
              ),
              const SizedBox(height: 4),
              value,
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Show QR code button + dialog
// ---------------------------------------------------------------------------

class _ShowQrCodeButton extends StatelessWidget {
  final String bookingId;
  const _ShowQrCodeButton({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.qr_code_rounded),
        label: const Text('Tampilkan QR Code'),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => _QrCodeDialog(bookingId: bookingId),
        ),
      ),
    );
  }
}

class _QrCodeDialog extends StatelessWidget {
  final String bookingId;
  const _QrCodeDialog({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'QR Tiket',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tunjukkan QR ini ke driver saat naik',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textCaption),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: QrImageView(
                data: bookingId,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ID: $bookingId',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action area
// ---------------------------------------------------------------------------

class _ActionArea extends StatelessWidget {
  final BookingDetailController controller;
  final BookingModel booking;

  const _ActionArea(
      {required this.controller, required this.booking});

  @override
  Widget build(BuildContext context) {
    // confirmed + trip assigned → show scan check-in
    if (booking.isConfirmed && booking.tripId != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan Check-In'),
          onPressed: () => Get.toNamed(
            Routes.USER_SCAN,
            arguments: booking.id,
          ),
        ),
      );
    }

    // boarded → show manual completion
    if (booking.isBoarded && !booking.isCompleted) {
      return Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flag_rounded),
              label: controller.isCompleting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Konfirmasi Selesai'),
              onPressed: controller.isCompleting.value
                  ? null
                  : controller.confirmComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
          ));
    }

    return const SizedBox.shrink();
  }
}

// ---------------------------------------------------------------------------
// Bus tracking card
// ---------------------------------------------------------------------------

class _BusTrackingCard extends StatelessWidget {
  final BookingDetailController controller;
  const _BusTrackingCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.directions_bus_rounded,
                    size: 18, color: AppColors.navy),
                const SizedBox(width: 8),
                Text(
                  'Lokasi Bus',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final t = controller.trip.value;

            if (t == null) {
              return const _TrackingPlaceholder(
                  message: 'Menunggu data perjalanan...');
            }
            if (!t.isActive) {
              return const _TrackingPlaceholder(
                  message: 'Perjalanan belum dimulai');
            }
            if (!t.hasLocation) {
              return const _TrackingPlaceholder(
                  message: 'Menunggu posisi bus...');
            }

            final busPos = LatLng(t.driverLatitude!, t.driverLongitude!);
            return SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: busPos, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId('bus'),
                    position: busPos,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                    infoWindow: const InfoWindow(title: 'Bus SirkelBus'),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: true,
                onMapCreated: controller.onMapCreated,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TrackingPlaceholder extends StatelessWidget {
  final String message;
  const _TrackingPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: AppColors.sectionBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_searching_rounded,
                size: 28, color: AppColors.textCaption),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  GoogleFonts.inter(fontSize: 13, color: AppColors.textCaption),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _StatusVisual {
  final String label;
  final String description;
  final Color fg;
  final Color bg;
  final IconData icon;
  const _StatusVisual(
      this.label, this.description, this.fg, this.bg, this.icon);
}

_StatusVisual _statusInfo(String? status) {
  switch (status) {
    case BookingStatus.confirmed:
      return const _StatusVisual(
        'Terkonfirmasi',
        'Tripmu sudah dikonfirmasi — siap untuk naik bus',
        AppColors.success,
        Color(0xFFDCFCE7),
        Icons.check_circle_rounded,
      );
    case BookingStatus.pending:
      return const _StatusVisual(
        'Dipesan',
        'Menunggu driver memulai perjalanan untuk mengonfirmasi tiketmu',
        AppColors.warning,
        Color(0xFFFEF3C7),
        Icons.hourglass_top_rounded,
      );
    case BookingStatus.cancelled:
      return const _StatusVisual(
        'Dibatalkan',
        'Pemesanan ini telah dibatalkan',
        AppColors.error,
        Color(0xFFFEE2E2),
        Icons.cancel_rounded,
      );
    case BookingStatus.completed:
      return const _StatusVisual(
        'Selesai',
        'Perjalanan telah selesai',
        AppColors.navy,
        AppColors.navyLight,
        Icons.flag_rounded,
      );
    default:
      return _StatusVisual(
        status ?? 'Tidak diketahui',
        '',
        AppColors.textCaption,
        AppColors.sectionBackground,
        Icons.help_outline_rounded,
      );
  }
}

String _formatDate(String? serviceDate) {
  if (serviceDate == null || serviceDate.isEmpty) return '-';
  final date = DateTime.tryParse(serviceDate);
  if (date == null) return serviceDate;
  return DateFormat('EEEE, d MMMM yyyy', 'id').format(date);
}

String _formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return DateFormat('d MMM yyyy, HH:mm', 'id').format(dt.toLocal());
}
