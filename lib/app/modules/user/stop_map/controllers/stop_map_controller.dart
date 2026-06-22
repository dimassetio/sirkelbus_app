import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../data/models/stop_model.dart';

class StopMapController extends GetxController {
  final stops = <StopModel>[].obs;
  final isLoading = true.obs;
  final selectedStop = Rx<StopModel?>(null);
  final currentPosition = Rx<LatLng?>(null);

  late final List<String> stopIds;
  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    stopIds = List<String>.from(Get.arguments as List? ?? []);
    _load();
  }

  Future<void> _load() async {
    isLoading(true);
    await _fetchLocation();
    final loaded = await StopModel.getByIds(stopIds);
    stops.assignAll(loaded);
    _selectNearest();
    isLoading(false);
  }

  Future<void> _fetchLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      currentPosition(LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  void _selectNearest() {
    if (stops.isEmpty) return;
    final pos = currentPosition.value;
    if (pos == null) {
      selectedStop(stops.first);
      return;
    }
    final nearest = stops.reduce((a, b) {
      final dA = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, a.lat ?? 0, a.lng ?? 0);
      final dB = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, b.lat ?? 0, b.lng ?? 0);
      return dA < dB ? a : b;
    });
    selectedStop(nearest);
  }

  void selectStop(StopModel stop) {
    selectedStop(stop);
    _animateTo(stop);
  }

  void _animateTo(StopModel stop) {
    if (stop.lat == null || stop.lng == null) return;
    mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(stop.lat!, stop.lng!)),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final sel = selectedStop.value;
    if (sel != null) _animateTo(sel);
  }

  void confirmSelection() {
    if (selectedStop.value != null) {
      Get.back(result: selectedStop.value);
    }
  }

  LatLng get initialCamera {
    final sel = selectedStop.value;
    if (sel?.lat != null) return LatLng(sel!.lat!, sel.lng!);
    final pos = currentPosition.value;
    if (pos != null) return pos;
    final first = stops.firstOrNull;
    if (first?.lat != null) return LatLng(first!.lat!, first.lng!);
    return const LatLng(-7.0, 107.9); // default: West Java
  }

  Set<Marker> buildMarkers() {
    return stops.map((s) {
      final isSelected = selectedStop.value?.id == s.id;
      return Marker(
        markerId: MarkerId(s.id ?? ''),
        position: LatLng(s.lat ?? 0, s.lng ?? 0),
        infoWindow: InfoWindow(title: s.name ?? '-'),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
            : BitmapDescriptor.defaultMarker,
        onTap: () => selectStop(s),
      );
    }).toSet();
  }
}
