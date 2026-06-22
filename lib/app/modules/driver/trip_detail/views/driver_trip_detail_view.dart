import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/trip_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/driver_trip_detail_controller.dart';

class DriverTripDetailView extends GetView<DriverTripDetailController> {
  const DriverTripDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: Text('Rute Perjalanan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.navy900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Tiket Penumpang',
            onPressed: () => Get.toNamed(Routes.DRIVER_SCAN, arguments: controller.tripId),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final trip = controller.trip.value;
        if (trip == null) {
          return const Center(child: Text('Trip tidak ditemukan.'));
        }

        final stops = <TripRouteStop>[...(trip.routeStops ?? [])]
          ..sort((a, b) => a.order.compareTo(b.order));
        if (stops.isEmpty) {
          return const Center(child: Text('Belum ada data rute untuk trip ini.'));
        }

        return Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  Obx(() => GoogleMap(
                        initialCameraPosition: CameraPosition(target: controller.initialCamera, zoom: 14),
                        markers: controller.buildMarkers(),
                        polylines: controller.buildPolylines(),
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: controller.onMapCreated,
                      )),
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: _LiveTrackingBar(controller: controller),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: _StopInfoPanel(controller: controller, trip: trip, stops: stops),
            ),
          ],
        );
      }),
    );
  }
}

class _LiveTrackingBar extends StatelessWidget {
  final DriverTripDetailController controller;
  const _LiveTrackingBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = controller.isLiveTracking.value;
      final isToggling = controller.isTogglingTracking.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 18,
              color: isLive ? AppColors.success : AppColors.textCaption,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isLive ? 'Live update aktif' : 'Live update nonaktif',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLive ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ),
            isToggling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: isLive,
                    onChanged: (_) => controller.toggleLiveTracking(),
                    activeThumbColor: AppColors.success,
                  ),
          ],
        ),
      );
    });
  }
}

class _StopInfoPanel extends StatelessWidget {
  final DriverTripDetailController controller;
  final TripModel trip;
  final List<TripRouteStop> stops;
  const _StopInfoPanel({required this.controller, required this.trip, required this.stops});

  @override
  Widget build(BuildContext context) {
    final directToDestination = trip.progress?.directToDestination ?? false;
    final destinationStop = stops.last;

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
          if (directToDestination)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bus penuh — menuju langsung ke ${destinationStop.name}'
                    '${trip.progress?.directRouteDistanceKm != null ? ' (${trip.progress!.directRouteDistanceKm} km)' : ''}, '
                    'lewati sisa halte.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final arriving = controller.arrivingStopId.value == destinationStop.stopId;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: arriving ? null : () => controller.arriveAtStop(destinationStop.stopId),
                        child: arriving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Tiba di tujuan'),
                      ),
                    );
                  }),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stops.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final stop = stops[index];
                final currentStopIndex = trip.progress?.currentStopIndex ?? 0;
                final isCurrent = index == currentStopIndex;
                final isPast = index < currentStopIndex;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrent ? AppColors.navy : AppColors.border,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isPast
                            ? AppColors.success
                            : (isCurrent ? AppColors.navy : AppColors.navyLight),
                        child: Icon(
                          isPast ? Icons.check_rounded : Icons.directions_bus_rounded,
                          size: 16,
                          color: isPast || isCurrent ? Colors.white : AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stop.name,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${stop.estimatedPassengers} penumpang diperkirakan',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textCaption),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent && !directToDestination)
                        Obx(() {
                          final arriving = controller.arrivingStopId.value == stop.stopId;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(64, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onPressed: arriving ? null : () => controller.arriveAtStop(stop.stopId),
                            child: arriving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Tiba di sini'),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
