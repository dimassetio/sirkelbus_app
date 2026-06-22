import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/helpers/database.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/route_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/stop_model.dart';
import '../../../../data/models/trip_model.dart';

class BookingDetailController extends GetxController {
  final booking = Rx<BookingModel?>(null);
  final trip = Rx<TripModel?>(null);
  final isLoading = true.obs;
  final isCompleting = false.obs;

  late final String bookingId;

  String _routeName = '-';
  String _routeDirection = '';
  String _departureTime = '-';
  String _pickupStopName = '-';

  String get routeName => _routeName;
  String get routeDirection => _routeDirection;
  String get departureTime => _departureTime;
  String get pickupStopName => _pickupStopName;

  GoogleMapController? _mapController;
  StreamSubscription<BookingModel?>? _bookingSub;
  StreamSubscription<TripModel?>? _tripSub;
  String? _watchingTripKey;
  Position? _userPosition;

  @override
  void onInit() {
    super.onInit();
    bookingId = Get.arguments as String? ?? '';
    _bookingSub = BookingModel.streamById(bookingId).listen((b) async {
      if (b != null && isLoading.value) {
        await _loadRelated(b);
      }
      booking(b);
      isLoading(false);
      _syncTripStream(b);
    });
    _loadUserPosition();
  }

  Future<void> _loadUserPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    _userPosition = await Geolocator.getCurrentPosition();
    _fitToMarkers();
  }

  void _syncTripStream(BookingModel? b) {
    final scheduleId = b?.scheduleId;
    final serviceDate = b?.serviceDate;
    final key = (scheduleId != null && serviceDate != null)
        ? '$scheduleId|$serviceDate'
        : null;
    if (key == _watchingTripKey) return;
    _tripSub?.cancel();
    _watchingTripKey = key;
    if (scheduleId == null || serviceDate == null) {
      trip(null);
      return;
    }
    _tripSub =
        TripModel.streamByScheduleAndDate(scheduleId, serviceDate).listen((t) async {
      trip(t);
      if (t != null && t.hasLocation) {
        await _fitToMarkers();
      }
    });
  }

  void onMapCreated(GoogleMapController c) {
    _mapController = c;
    _fitToMarkers();
  }

  Future<void> _fitToMarkers() async {
    final c = _mapController;
    final t = trip.value;
    if (c == null || t == null || !t.hasLocation) return;
    final busPos = LatLng(t.driverLatitude!, t.driverLongitude!);
    final userPos = _userPosition;
    if (userPos == null) {
      await c.animateCamera(CameraUpdate.newLatLng(busPos));
      return;
    }
    final points = [busPos, LatLng(userPos.latitude, userPos.longitude)];
    final minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    await c.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        64,
      ),
    );
  }

  Future<void> _loadRelated(BookingModel b) async {
    if (b.scheduleId != null) {
      final schedules = await ScheduleModel.streamAll().first;
      final schedule =
          schedules.firstWhereOrNull((s) => s.id == b.scheduleId);
      if (schedule != null) {
        _departureTime = schedule.departureTime ?? '-';
        _routeDirection = schedule.routeDirection ?? '';
        if (schedule.routeId != null) {
          final routes = await RouteModel.streamAll().first;
          final route =
              routes.firstWhereOrNull((r) => r.id == schedule.routeId);
          _routeName = route?.name ?? schedule.name ?? '-';
        }
      }
    }
    if (b.pickupStopId != null && b.pickupStopId!.isNotEmpty) {
      final stops = await StopModel.getByIds([b.pickupStopId!]);
      if (stops.isNotEmpty) _pickupStopName = stops.first.name ?? '-';
    }
  }

  Future<void> confirmComplete() async {
    final b = booking.value;
    if (b?.id == null) return;
    isCompleting(true);
    try {
      await firestore
          .collection(BookingModel.collectionName)
          .doc(b!.id)
          .update({'status': BookingStatus.completed});
      Get.snackbar(
        'Selesai',
        'Perjalanan dikonfirmasi selesai.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      Get.snackbar('Gagal', e.message ?? 'Terjadi kesalahan.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCompleting(false);
    }
  }

  @override
  void onClose() {
    _bookingSub?.cancel();
    _tripSub?.cancel();
    _mapController?.dispose();
    super.onClose();
  }
}
