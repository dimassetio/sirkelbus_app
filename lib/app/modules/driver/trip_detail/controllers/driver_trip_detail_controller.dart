import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/stop_model.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/location_service.dart';
import '../../../../utils/app_colors.dart';

class DriverTripDetailController extends GetxController {
  final trip = Rx<TripModel?>(null);
  final isLoading = true.obs;
  final arrivingStopId = RxnString();
  final stops = <StopModel>[].obs;
  final isLiveTracking = false.obs;
  final isTogglingTracking = false.obs;

  late final String tripId;
  StreamSubscription<TripModel?>? _tripSub;
  GoogleMapController? _mapController;
  List<String>? _loadedStopIds;
  bool _boundsFitted = false;

  @override
  void onInit() {
    super.onInit();
    tripId = Get.arguments as String? ?? '';
    isLiveTracking(LocationService.instance.isTracking &&
        LocationService.instance.currentTripId == tripId);
    _tripSub = TripModel.streamById(tripId).listen((t) async {
      trip(t);
      isLoading(false);
      await _loadStopsIfNeeded(t);
    });
  }

  Future<void> _loadStopsIfNeeded(TripModel? t) async {
    final stopIds = (t?.routeStops ?? [])..sort((a, b) => a.order.compareTo(b.order));
    final ids = stopIds.map((s) => s.stopId).toList();
    if (ids.isEmpty || _listEquals(ids, _loadedStopIds)) return;
    _loadedStopIds = ids;
    final loaded = await StopModel.getByIds(ids);
    final byId = {for (final s in loaded) s.id: s};
    stops.assignAll(ids.map((id) => byId[id]).whereType<StopModel>());
    _fitBounds();
  }

  bool _listEquals(List<String> a, List<String>? b) {
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int get currentStopIndex => trip.value?.progress?.currentStopIndex ?? 0;

  Set<Marker> buildMarkers() {
    final markers = <Marker>{};
    for (var i = 0; i < stops.length; i++) {
      final s = stops[i];
      if (s.lat == null || s.lng == null) continue;
      final isPassed = i < currentStopIndex;
      final isCurrent = i == currentStopIndex;
      markers.add(Marker(
        markerId: MarkerId('stop_${s.id}'),
        position: LatLng(s.lat!, s.lng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isCurrent
              ? BitmapDescriptor.hueCyan
              : isPassed
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueOrange,
        ),
        infoWindow: InfoWindow(title: '${i + 1}. ${s.name ?? '-'}'),
      ));
    }
    final t = trip.value;
    if (isLiveTracking.value && t != null && t.hasLocation) {
      markers.add(Marker(
        markerId: const MarkerId('bus'),
        position: LatLng(t.driverLatitude!, t.driverLongitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Posisi Bus Anda'),
      ));
    }
    return markers;
  }

  Set<Polyline> buildPolylines() {
    final points = stops
        .where((s) => s.lat != null && s.lng != null)
        .map((s) => LatLng(s.lat!, s.lng!))
        .toList();
    if (points.length < 2) return {};

    final polylines = <Polyline>{};
    for (var i = 0; i < points.length - 1; i++) {
      final isPassed = i < currentStopIndex;
      final isCurrentLeg = i == currentStopIndex;
      polylines.add(Polyline(
        polylineId: PolylineId('leg_$i'),
        points: [points[i], points[i + 1]],
        color: isPassed
            ? AppColors.textDisabled
            : isCurrentLeg
                ? AppColors.skyBlue
                : AppColors.navy,
        width: isCurrentLeg ? 5 : 3,
      ));
    }

    final directPath = trip.value?.progress?.directRoutePath;
    if (directPath != null && directPath.length >= 2) {
      final byId = {for (final s in stops) s.id: s};
      final overridePoints = directPath
          .map((id) => byId[id])
          .whereType<StopModel>()
          .where((s) => s.lat != null && s.lng != null)
          .map((s) => LatLng(s.lat!, s.lng!))
          .toList();
      if (overridePoints.length >= 2) {
        polylines.add(Polyline(
          polylineId: const PolylineId('direct_override'),
          points: overridePoints,
          color: AppColors.error,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ));
      }
    }

    return polylines;
  }

  LatLng get initialCamera {
    final stopWithLatLng = stops.firstWhereOrNull((s) => s.lat != null && s.lng != null);
    if (stopWithLatLng != null) return LatLng(stopWithLatLng.lat!, stopWithLatLng.lng!);
    return const LatLng(-7.0, 107.9);
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    if (_mapController == null || _boundsFitted) return;
    final points = stops.where((s) => s.lat != null && s.lng != null).map((s) => LatLng(s.lat!, s.lng!)).toList();
    if (points.length < 2) return;
    _boundsFitted = true;
    var minLat = points.first.latitude, maxLat = points.first.latitude;
    var minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
        48,
      ),
    );
  }

  Future<void> toggleLiveTracking() async {
    if (isTogglingTracking.value) return;
    isTogglingTracking(true);
    try {
      if (isLiveTracking.value) {
        await LocationService.instance.stopTracking();
        isLiveTracking(false);
        Get.snackbar(
          'Live Update Dimatikan',
          'Lokasi bus tidak lagi dibagikan.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await LocationService.instance.startTracking(tripId);
        isLiveTracking(LocationService.instance.isTracking);
        if (isLiveTracking.value) {
          Get.snackbar(
            'Live Update Aktif',
            'Lokasi bus sedang dibagikan secara real-time.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } finally {
      isTogglingTracking(false);
    }
  }

  Future<void> arriveAtStop(String stopId) async {
    arrivingStopId(stopId);
    try {
      await ApiClient.instance.dio.post(
        '/trips/$tripId/arrive-stop',
        data: {'stopId': stopId},
      );
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar('Gagal', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Force a fresh server read instead of waiting on the live listener —
      // guarantees the page reflects the outcome right away whether the call
      // succeeded or failed, instead of looking stuck until next refresh.
      await _refreshTrip();
      arrivingStopId(null);
    }
  }

  Future<void> _refreshTrip() async {
    try {
      final fresh = await TripModel.getById(tripId);
      if (fresh != null) trip(fresh);
    } catch (_) {}
  }

  @override
  void onClose() {
    _tripSub?.cancel();
    _mapController?.dispose();
    super.onClose();
  }
}
