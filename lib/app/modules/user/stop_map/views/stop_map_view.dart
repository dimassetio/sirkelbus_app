import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/stop_model.dart';
import '../../../../utils/app_colors.dart';
import '../controllers/stop_map_controller.dart';

class StopMapView extends GetView<StopMapController> {
  const StopMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Pilih Halte',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'Ketuk penanda halte di peta untuk memilih',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
        ),
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
                const Icon(Icons.location_off_outlined,
                    size: 48, color: AppColors.textCaption),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada halte tersedia',
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

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: controller.initialCamera,
                zoom: 14,
              ),
              markers: controller.buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: controller.onMapCreated,
            ),
            // Stop list as horizontal chips at top
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _StopChipList(controller: controller),
            ),
            // Selected stop panel at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SelectedStopPanel(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal scrollable stop chip list
// ---------------------------------------------------------------------------

class _StopChipList extends StatelessWidget {
  final StopMapController controller;
  const _StopChipList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final selected = controller.selectedStop.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: controller.stops.length,
          separatorBuilder: (_, _) => const SizedBox(width: 4),
          itemBuilder: (_, i) {
            final stop = controller.stops[i];
            final isSelected = selected?.id == stop.id;
            return Center(
              child: GestureDetector(
                onTap: () => controller.selectStop(stop),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    stop.name ?? '-',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected stop info panel
// ---------------------------------------------------------------------------

class _SelectedStopPanel extends StatelessWidget {
  final StopMapController controller;
  const _SelectedStopPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stop = controller.selectedStop.value;
      if (stop == null) return const SizedBox.shrink();

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _StopDetailRow(stop: stop),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.confirmSelection,
                child: const Text('Pilih Halte Ini'),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StopDetailRow extends StatelessWidget {
  final StopModel stop;
  const _StopDetailRow({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.location_on_rounded,
              color: AppColors.navy, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.name ?? '-',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (stop.displayLocation.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  stop.displayLocation,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textCaption),
                ),
              ],
              if (stop.addressDetail != null &&
                  stop.addressDetail!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  stop.addressDetail!,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textCaption),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
