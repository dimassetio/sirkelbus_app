import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/booking_model.dart';
import '../../../../data/models/route_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/stop_model.dart';
import '../../../../data/services/api_client.dart';
import '../../../../routes/app_pages.dart';

class DriverRoutePreviewController extends GetxController {
  final isLoading = true.obs;
  final stops = <StopModel>[].obs;
  final routeName = ''.obs;

  final selectedDate = DateTime.now().obs;
  final isLoadingBookings = false.obs;
  final bookingCountByStop = <String, int>{}.obs;
  final isStarting = false.obs;

  late final ScheduleModel schedule;
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    schedule = Get.arguments as ScheduleModel;
    _load();
  }

  Future<void> _load() async {
    isLoading(true);
    final routeId = schedule.routeId;
    if (routeId == null) {
      isLoading(false);
      return;
    }
    final route = await RouteModel.getById(routeId);
    routeName(route?.name ?? schedule.name ?? '-');
    if (route != null) {
      final loaded = await StopModel.getByIds(route.stopIds);
      final byId = {for (final s in loaded) s.id: s};
      stops.assignAll(
        route.stopIds.map((id) => byId[id]).whereType<StopModel>(),
      );
    }
    isLoading(false);
    await _loadBookings();
  }

  String get selectedServiceDate =>
      DateFormat('yyyy-MM-dd').format(selectedDate.value);

  bool get isSelectedDateToday {
    final now = DateTime.now();
    final d = selectedDate.value;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Future<void> pickDate(DateTime date) async {
    selectedDate(date);
    await _loadBookings();
  }

  Future<void> _loadBookings() async {
    final scheduleId = schedule.id;
    if (scheduleId == null) return;
    isLoadingBookings(true);
    try {
      final bookings = await BookingModel.getActiveForSchedule(
        scheduleId: scheduleId,
        serviceDate: selectedServiceDate,
      );
      final counts = <String, int>{};
      for (final booking in bookings) {
        final stopId = booking.pickupStopId;
        if (stopId == null) continue;
        counts[stopId] = (counts[stopId] ?? 0) + 1;
      }
      bookingCountByStop.assignAll(counts);
    } finally {
      isLoadingBookings(false);
    }
  }

  int bookingCountFor(StopModel stop) => bookingCountByStop[stop.id] ?? 0;

  int get totalEstimatedBookings =>
      bookingCountByStop.values.fold(0, (a, b) => a + b);

  List<LatLng> get polylinePoints => stops
      .where((s) => s.lat != null && s.lng != null)
      .map((s) => LatLng(s.lat!, s.lng!))
      .toList();

  Set<Marker> buildMarkers() {
    return stops.asMap().entries.where((e) => e.value.lat != null && e.value.lng != null).map((e) {
      final index = e.key;
      final stop = e.value;
      return Marker(
        markerId: MarkerId(stop.id ?? index.toString()),
        position: LatLng(stop.lat!, stop.lng!),
        infoWindow: InfoWindow(title: '${index + 1}. ${stop.name ?? '-'}'),
      );
    }).toSet();
  }

  LatLng get initialCamera {
    final points = polylinePoints;
    if (points.isEmpty) return const LatLng(-7.0, 107.9);
    return points.first;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    final points = polylinePoints;
    if (points.length < 2 || mapController == null) return;
    var minLat = points.first.latitude, maxLat = points.first.latitude;
    var minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = p.latitude < minLat ? p.latitude : minLat;
      maxLat = p.latitude > maxLat ? p.latitude : maxLat;
      minLng = p.longitude < minLng ? p.longitude : minLng;
      maxLng = p.longitude > maxLng ? p.longitude : maxLng;
    }
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        48,
      ),
    );
  }

  Future<void> startTrip() async {
    if (schedule.id == null || isStarting.value) return;
    isStarting(true);
    try {
      final response = await ApiClient.instance.dio.post(
        '/startTrip',
        data: {'scheduleId': schedule.id, 'serviceDate': selectedServiceDate},
      );
      final tripId = (response.data as Map?)?['trip']?['id'] as String?;
      if (tripId == null) {
        throw Exception('Trip tidak berhasil dibuat.');
      }
      Get.snackbar(
        'Perjalanan Dimulai',
        'Aktifkan live update di halaman trip untuk membagikan lokasi bus.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offNamed(Routes.DRIVER_TRIP_DETAIL, arguments: tripId);
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar('Gagal', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isStarting(false);
    }
  }
}
