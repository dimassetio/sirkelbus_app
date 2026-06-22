import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/stop_model.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/driver_route_preview_controller.dart';

class DriverRoutePreviewView extends GetView<DriverRoutePreviewController> {
  const DriverRoutePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Obx(
          () => Text(
            controller.routeName.value.isEmpty
                ? 'Preview Rute'
                : controller.routeName.value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            tooltip: 'Pilih tanggal',
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.navy),
          );
        }

        if (controller.stops.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.alt_route_outlined,
                    size: 48, color: AppColors.textCaption),
                const SizedBox(height: 12),
                Text(
                  'Rute belum tersedia',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              flex: 5,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.initialCamera,
                  zoom: 13,
                ),
                markers: controller.buildMarkers(),
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: controller.polylinePoints,
                    color: AppColors.navy,
                    width: 4,
                  ),
                },
                zoomControlsEnabled: false,
                onMapCreated: controller.onMapCreated,
              ),
            ),
            Expanded(
              flex: 5,
              child: _StopListPanel(controller: controller),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      controller.pickDate(picked);
    }
  }
}

class _StopListPanel extends StatelessWidget {
  final DriverRoutePreviewController controller;
  const _StopListPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SimulationHeader(controller: controller),
          Expanded(
            child: Obx(
              () => controller.isLoadingBookings.value
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.navy, strokeWidth: 2),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      itemCount: controller.stops.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final stop = controller.stops[i];
                        return _StopRow(
                          order: i + 1,
                          stop: stop,
                          estimatedBookings: controller.bookingCountFor(stop),
                        );
                      },
                    ),
            ),
          ),
          _StartTripBar(controller: controller),
        ],
      ),
    );
  }
}

class _SimulationHeader extends StatelessWidget {
  final DriverRoutePreviewController controller;
  const _SimulationHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulasi Perjalanan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'id')
                      .format(controller.selectedDate.value),
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textCaption),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.navyLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.totalEstimatedBookings} estimasi penumpang',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartTripBar extends StatelessWidget {
  final DriverRoutePreviewController controller;
  const _StartTripBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Obx(() {
        final isToday = controller.isSelectedDateToday;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: (!isToday || controller.isStarting.value)
                ? null
                : controller.startTrip,
            icon: controller.isStarting.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(
              isToday ? 'Mulai Perjalanan' : 'Hanya untuk tanggal hari ini',
            ),
          ),
        );
      }),
    );
  }
}

class _StopRow extends StatelessWidget {
  final int order;
  final StopModel stop;
  final int estimatedBookings;
  const _StopRow({
    required this.order,
    required this.stop,
    required this.estimatedBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.navyLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$order',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.name ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (stop.displayLocation.isNotEmpty)
                Text(
                  stop.displayLocation,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textCaption),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.sectionBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people_outline_rounded,
                  size: 14, color: AppColors.textCaption),
              const SizedBox(width: 4),
              Text(
                '$estimatedBookings',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
