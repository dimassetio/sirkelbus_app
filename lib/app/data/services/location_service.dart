import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../helpers/database.dart';
import '../models/trip_model.dart';

/// Minimum time between two sent updates, even if the device hasn't moved.
const _heartbeatInterval = Duration(seconds: 5);

/// Minimum movement (meters) from the last *sent* position that triggers an
/// immediate update, even if [_heartbeatInterval] hasn't elapsed yet.
const _minDistanceMeters = 5.0;

class LocationService {
  LocationService._();
  static final instance = LocationService._();

  StreamSubscription<Position>? _positionSub;
  Timer? _heartbeatTimer;
  String? _tripId;

  Position? _lastKnownPosition;
  Position? _lastSentPosition;
  DateTime? _lastSentAt;

  bool get isTracking => _positionSub != null;
  String? get currentTripId => _tripId;

  Future<void> startTracking(String tripId) async {
    await stopTracking();

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Izin Lokasi',
        'Izin lokasi diperlukan untuk berbagi posisi bus.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _tripId = tripId;
    _lastKnownPosition = null;
    _lastSentPosition = null;
    _lastSentAt = null;

    // distanceFilter: 0 — every raw OS sample reaches us; the 5s-or-5m
    // throttle below decides which samples actually get sent to Firestore.
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen(_onPosition);

    // Guarantees an update at least every 5s even while the bus is
    // stationary, when no new position-changed event fires at all.
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      final pos = _lastKnownPosition;
      final lastSentAt = _lastSentAt;
      if (pos == null) return;
      if (lastSentAt == null || DateTime.now().difference(lastSentAt) >= _heartbeatInterval) {
        _send(pos);
      }
    });
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _tripId = null;
    _lastKnownPosition = null;
    _lastSentPosition = null;
    _lastSentAt = null;
  }

  void _onPosition(Position pos) {
    _lastKnownPosition = pos;

    final lastSent = _lastSentPosition;
    if (lastSent == null) {
      _send(pos);
      return;
    }

    final distance = Geolocator.distanceBetween(
      lastSent.latitude,
      lastSent.longitude,
      pos.latitude,
      pos.longitude,
    );

    if (distance >= _minDistanceMeters) {
      _send(pos);
    }
  }

  void _send(Position pos) {
    final id = _tripId;
    if (id == null) return;

    _lastSentPosition = pos;
    _lastSentAt = DateTime.now();

    firestore.collection(TripModel.collectionName).doc(id).update({
      'driverLatitude': pos.latitude,
      'driverLongitude': pos.longitude,
    });
  }
}
