import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/driver_home_controller.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final ratioHeight = screenHeight * 0.32;

    // final heroHeight = min(ratioHeight, 200.0);
    final heroHeight = 200.0;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SizedBox.expand(
        child: Stack(
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
                child: _TripList(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(double heroHeight) {
    return Container(
      width: double.infinity,
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
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 16,
                children: [
                  InkWell(
                    onTap: () => Get.toNamed(Routes.USER_PROFILE),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.navyLight,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel Driver',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
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
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id',
                    ).format(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
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
}

// ---------------------------------------------------------------------------
// Trip list
// ---------------------------------------------------------------------------

class _TripList extends StatelessWidget {
  final DriverHomeController controller;
  const _TripList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = <Widget>[
        _ScheduleSection(controller: controller),
        const SizedBox(height: 8),
      ];

      if (controller.isLoading.value) {
        items.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.navy),
            ),
          ),
        );
      } else if (controller.trips.isEmpty) {
        items.add(_buildEmpty());
      } else {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Trip Hari Ini',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
        for (final trip in controller.trips) {
          items.add(_TripCard(controller: controller, trip: trip));
        }
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: items,
      );
    });
  }

  Widget _buildEmpty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Hari Ini',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
                child: const Icon(
                  Icons.drive_eta_outlined,
                  size: 32,
                  color: AppColors.navy,
                ),
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
                'Trip yang ditugaskan akan muncul di sini',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textCaption,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: controller.signOut,
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Keluar'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Assigned bus & schedule section
// ---------------------------------------------------------------------------

class _ScheduleSection extends StatelessWidget {
  final DriverHomeController controller;
  const _ScheduleSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSchedules.value) {
        return const SizedBox.shrink();
      }
      if (controller.schedules.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Bus & Jadwal Saya',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          for (final schedule in controller.schedules)
            _ScheduleCard(controller: controller, schedule: schedule),
          const SizedBox(height: 8),
        ],
      );
    });
  }
}

class _ScheduleCard extends StatelessWidget {
  final DriverHomeController controller;
  final ScheduleModel schedule;
  const _ScheduleCard({required this.controller, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.navyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 20,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.routeNameFor(schedule),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${schedule.departureTime ?? '-'} • ${controller.busLabelFor(schedule)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(
                      Routes.DRIVER_ROUTE_PREVIEW,
                      arguments: schedule,
                    ),
                    icon: const Icon(Icons.alt_route_rounded, size: 18),
                    label: const Text('Lihat Rute'),
                  ),
                ),
                // const SizedBox(width: 8),
                // Expanded(
                //   child: _ScheduleStartButton(
                //     controller: controller,
                //     schedule: schedule,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleStartButton extends StatelessWidget {
  final DriverHomeController controller;
  final ScheduleModel schedule;
  const _ScheduleStartButton({
    required this.controller,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final existingTrip = controller.tripForSchedule(schedule.id);
      if (existingTrip != null) {
        return ElevatedButton.icon(
          onPressed: existingTrip.id == null
              ? null
              : () => Get.toNamed(
                  Routes.DRIVER_TRIP_DETAIL,
                  arguments: existingTrip.id,
                ),
          icon: const Icon(Icons.directions_bus_rounded, size: 18),
          label: const Text('Lihat Trip'),
        );
      }
      final processing = controller.processingScheduleId.value == schedule.id;
      return ElevatedButton.icon(
        onPressed: processing
            ? null
            : () => controller.startScheduleTrip(schedule),
        icon: processing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.play_arrow_rounded, size: 18),
        label: const Text('Mulai Perjalanan'),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Trip card
// ---------------------------------------------------------------------------

class _TripCard extends StatelessWidget {
  final DriverHomeController controller;
  final TripModel trip;
  const _TripCard({required this.controller, required this.trip});

  @override
  Widget build(BuildContext context) {
    final isActive = trip.isActive;
    return GestureDetector(
      onTap: isActive && trip.id != null
          ? () => Get.toNamed(Routes.DRIVER_TRIP_DETAIL, arguments: trip.id)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.navy : AppColors.border,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.navy : AppColors.navyLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.directions_bus_rounded,
                    size: 22,
                    color: isActive ? Colors.white : AppColors.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.routeTemplateName ??
                            'Trip ${trip.id?.substring(0, 8) ?? '-'}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        trip.serviceDate ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textCaption,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(isActive: isActive, status: trip.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.people_outline_rounded,
                  label: '${trip.passengerCount} penumpang',
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.location_on_rounded,
                    label: 'Lokasi aktif',
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final processing = controller.processingTripId.value == trip.id;
              if (isActive) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: processing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.flag_rounded, size: 18),
                    label: const Text('Selesaikan Perjalanan'),
                    onPressed: processing
                        ? null
                        : () => controller.endTrip(trip),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                );
              }
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Mulai Perjalanan'),
                  onPressed: processing
                      ? null
                      : () => controller.startTrip(trip),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  final String? status;
  const _StatusChip({required this.isActive, required this.status});

  @override
  Widget build(BuildContext context) {
    final label = isActive
        ? 'Aktif'
        : status == TripStatus.completed
        ? 'Selesai'
        : 'Menunggu';
    final color = isActive
        ? AppColors.success
        : status == TripStatus.completed
        ? AppColors.textCaption
        : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = AppColors.textCaption,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: color)),
      ],
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
