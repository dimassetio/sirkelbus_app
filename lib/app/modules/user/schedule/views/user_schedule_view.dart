import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/stop_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/user_schedule_controller.dart';

class UserScheduleView extends GetView<UserScheduleController> {
  const UserScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildDirectionToggle(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.navy),
                );
              }

              final list = controller.filteredSchedules;

              if (list.isEmpty) {
                return _buildEmpty();
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final schedule = list[i];
                  return Obx(
                    () => _ScheduleCard(
                      schedule: schedule,
                      routeName: controller.routeNameFor(schedule),
                      serviceDate: DateFormat(
                        'yyyy-MM-dd',
                      ).format(controller.selectedDate.value),
                      onTap: () => _showBookingSheet(context, schedule),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        'Jadwal Bus',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        Obx(
          () => TextButton.icon(
            onPressed: controller.pickDate,
            icon: const Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: Colors.white70,
            ),
            label: Text(
              DateFormat('d MMM', 'id').format(controller.selectedDate.value),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildDirectionToggle() {
    return Obx(() {
      final selected = controller.selectedDirection.value;
      return Container(
        color: AppColors.navy,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _DirectionTab(
                label: 'Pergi ke Sekolah',
                icon: Icons.school_outlined,
                isActive: selected == ScheduleDirection.toSchool,
                onTap: () =>
                    controller.selectedDirection(ScheduleDirection.toSchool),
              ),
              _DirectionTab(
                label: 'Pulang dari Sekolah',
                icon: Icons.home_outlined,
                isActive: selected == ScheduleDirection.fromSchool,
                onTap: () =>
                    controller.selectedDirection(ScheduleDirection.fromSchool),
              ),
            ],
          ),
        ),
      );
    });
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
              Icons.directions_bus_outlined,
              size: 36,
              color: AppColors.textCaption,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada bus pada tanggal ini',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textCaption,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(schedule: schedule),
    );
  }
}

// ---------------------------------------------------------------------------
// Direction tab
// ---------------------------------------------------------------------------

class _DirectionTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _DirectionTab({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? AppColors.navy : Colors.white70,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? AppColors.navy : Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule card
// ---------------------------------------------------------------------------

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final String routeName;
  final String serviceDate;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.schedule,
    required this.routeName,
    required this.serviceDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bookingOpen = schedule.isBookingOpen(serviceDate);

    return GestureDetector(
      onTap: bookingOpen ? onTap : null,
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
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: bookingOpen
                    ? AppColors.navyLight
                    : AppColors.sectionBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    schedule.departureTime ?? '--:--',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: bookingOpen
                          ? AppColors.navy
                          : AppColors.textCaption,
                    ),
                  ),
                  if (schedule.arrivalTimeEstimate != null &&
                      schedule.arrivalTimeEstimate!.isNotEmpty)
                    Text(
                      schedule.arrivalTimeEstimate!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textCaption,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
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
                  if (schedule.routeDirection != null &&
                      schedule.routeDirection!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      schedule.routeDirection!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (schedule.arrivalEstimateMinutes != null &&
                          schedule.arrivalEstimateMinutes! > 0)
                        _Chip(
                          icon: Icons.schedule_rounded,
                          label: '${schedule.arrivalEstimateMinutes} mnt',
                          color: AppColors.skyBlue,
                          bg: AppColors.skyBlueLight,
                        ),
                      const SizedBox(width: 6),
                      _Chip(
                        icon: bookingOpen
                            ? Icons.check_circle_outline_rounded
                            : Icons.lock_outline_rounded,
                        label: bookingOpen ? 'Buka' : 'Tutup',
                        color: bookingOpen
                            ? AppColors.success
                            : AppColors.textCaption,
                        bg: bookingOpen
                            ? const Color(0xFFDCFCE7)
                            : AppColors.sectionBackground,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (bookingOpen)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textCaption,
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Booking bottom sheet
// ---------------------------------------------------------------------------

class _BookingSheet extends StatefulWidget {
  final ScheduleModel schedule;
  const _BookingSheet({required this.schedule});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  StopModel? _selectedStop;

  Future<void> _pickStop() async {
    final c = Get.find<UserScheduleController>();
    final stopIds = c.stopIdsFor(widget.schedule);
    if (stopIds.isEmpty) {
      Get.snackbar(
        'Tidak ada halte',
        'Jadwal ini belum memiliki data halte.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final result = await Get.toNamed(Routes.USER_STOP_MAP, arguments: stopIds);
    if (result is StopModel && mounted) {
      setState(() => _selectedStop = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<UserScheduleController>();
    final routeName = c.routeNameFor(widget.schedule);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pesan Tiket',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.navyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_bus_rounded,
                  color: AppColors.navy,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        'Keberangkatan ${widget.schedule.departureTime ?? '-'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal',
            value: Obx(
              () => Text(
                DateFormat(
                  'EEEE, d MMMM yyyy',
                  'id',
                ).format(c.selectedDate.value),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label:
                '${widget.schedule.routeDirection == 'pulang' ? 'Titik Turun' : 'Titik Naik'}',
            value: GestureDetector(
              onTap: _pickStop,
              child: _selectedStop == null
                  ? Row(
                      children: [
                        Text(
                          'Pilih dari peta',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.skyBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.map_outlined,
                          size: 16,
                          color: AppColors.skyBlue,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStop!.name ?? '-',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_selectedStop!.displayLocation.isNotEmpty)
                          Text(
                            _selectedStop!.displayLocation,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textCaption,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketuk untuk ubah',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.skyBlue,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final serviceDate = DateFormat(
              'yyyy-MM-dd',
            ).format(c.selectedDate.value);
            final bookingOpen = widget.schedule.isBookingOpen(serviceDate);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!bookingOpen)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Waktu pemesanan sudah ditutup',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_selectedStop == null ||
                            c.isBooking.value ||
                            !bookingOpen)
                        ? null
                        : () => c.book(
                            schedule: widget.schedule,
                            pickupStopId: _selectedStop!.id!,
                          ),
                    child: c.isBooking.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Pesan Sekarang'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.sectionBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textCaption,
                ),
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
