import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/helpers/database.dart';
import '../../../../data/models/booking_model.dart';
import '../../../../data/models/bus_model.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/models/route_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/trip_model.dart';
import '../../../../data/services/api_client.dart';
import '../../../../data/services/location_service.dart';
import '../../../../routes/app_pages.dart';
import '../../../auth/controllers/auth_controller.dart';

class DriverHomeController extends GetxController {
  final trips = <TripModel>[].obs;
  final schedules = <ScheduleModel>[].obs;
  final isLoading = true.obs;
  final isLoadingSchedules = true.obs;
  final processingTripId = RxnString();
  final processingScheduleId = RxnString();
  final routeNameById = <String, String>{}.obs;
  final busLabelById = <String, String>{}.obs;

  StreamSubscription<List<TripModel>>? _tripSub;
  StreamSubscription<List<ScheduleModel>>? _scheduleSub;

  @override
  void onInit() {
    super.onInit();
    final uid = authC.firebaseUser.value?.uid;
    if (uid == null) return;
    _load(uid);
  }

  // schedules/trips reference drivers by their `drivers` collection doc id
  // (e.g. "DRV-005"), not the Firebase Auth uid, so that doc id must be
  // resolved before either stream can filter to "mine".
  Future<void> _load(String uid) async {
    final driverDocId = await DriverModel.docIdForUser(uid);
    if (driverDocId == null) {
      isLoading(false);
      isLoadingSchedules(false);
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _tripSub = TripModel.streamByDriver(driverDocId, today).listen((list) {
      trips(list);
      isLoading(false);
    });
    _scheduleSub = ScheduleModel.streamAll().listen((list) {
      final mine = list
          .where((s) =>
              s.driverId == driverDocId || s.driverIds.contains(driverDocId))
          .toList();
      schedules(mine);
      isLoadingSchedules(false);
      _resolveScheduleLabels(mine);
    });
  }

  Future<void> _resolveScheduleLabels(List<ScheduleModel> mine) async {
    final routeIds = mine.map((s) => s.routeId).whereType<String>().toSet();
    final busIds = mine
        .expand((s) => s.busId != null ? [s.busId!, ...s.busIds] : s.busIds)
        .toSet();

    final routes = await Future.wait(routeIds.map(RouteModel.getById));
    for (final r in routes) {
      if (r?.id != null) routeNameById[r!.id!] = r.name ?? r.id!;
    }

    final buses = await BusModel.getByIds(busIds.toList());
    for (final b in buses) {
      if (b.id != null) busLabelById[b.id!] = b.displayLabel;
    }
  }

  String routeNameFor(ScheduleModel s) =>
      routeNameById[s.routeId] ?? s.name ?? '-';

  String busLabelFor(ScheduleModel s) {
    final ids = s.busId != null ? [s.busId!, ...s.busIds] : s.busIds;
    final labels = ids.map((id) => busLabelById[id]).whereType<String>();
    return labels.isEmpty ? 'Belum ada bus' : labels.join(', ');
  }

  bool isProcessing(String? tripId) => processingTripId.value == tripId;

  TripModel? tripForSchedule(String? scheduleId) {
    if (scheduleId == null) return null;
    return trips.firstWhereOrNull((t) => t.scheduleId == scheduleId);
  }

  Future<void> startScheduleTrip(ScheduleModel schedule) async {
    if (schedule.id == null) return;
    processingScheduleId(schedule.id);
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await ApiClient.instance.dio.post(
        '/startTrip',
        data: {'scheduleId': schedule.id, 'serviceDate': today},
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
      Get.toNamed(Routes.DRIVER_TRIP_DETAIL, arguments: tripId);
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar('Gagal', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      processingScheduleId(null);
    }
  }

  Future<void> startTrip(TripModel trip) async {
    if (trip.id == null) return;
    processingTripId(trip.id);
    try {
      await ApiClient.instance.dio.post(
        '/updateTripStatus',
        data: {'tripId': trip.id, 'status': TripStatus.started},
      );
      Get.snackbar(
        'Perjalanan Dimulai',
        'Aktifkan live update di halaman trip untuk membagikan lokasi bus.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar('Gagal', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      processingTripId(null);
    }
  }

  Future<void> endTrip(TripModel trip) async {
    final tripId = trip.id;
    if (tripId == null) return;
    processingTripId(tripId);
    try {
      await LocationService.instance.stopTracking();
      await ApiClient.instance.dio.post(
        '/updateTripStatus',
        data: {'tripId': tripId, 'status': TripStatus.completed},
      );
      Get.snackbar(
        'Perjalanan Selesai',
        'Perjalanan telah diselesaikan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['error'] as String? ??
          e.message ??
          'Terjadi kesalahan.';
      Get.snackbar('Gagal', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Gagal', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Force a fresh server read instead of waiting on the live listener —
      // guarantees the page reflects the outcome right away whether the call
      // succeeded or failed, instead of looking stuck until next refresh.
      await _refreshTrip(tripId);
      processingTripId(null);
    }

    // Best-effort cleanup, run after the loading indicator has already
    // cleared — a slow/failed batch write here must never leave the
    // "Selesaikan Perjalanan" button stuck in its loading state.
    unawaited(_completePassengers(tripId).catchError((e) {
      Get.snackbar(
        'Gagal',
        'Sebagian penumpang belum diselesaikan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }));
  }

  Future<void> _refreshTrip(String tripId) async {
    try {
      final fresh = await TripModel.getById(tripId);
      if (fresh == null) return;
      final idx = trips.indexWhere((t) => t.id == tripId);
      if (idx != -1) trips[idx] = fresh;
    } catch (_) {}
  }

  Future<void> _completePassengers(String tripId) async {
    final snap = await firestore
        .collection(BookingModel.collectionName)
        .where('tripId', isEqualTo: tripId)
        .get();
    final batch = firestore.batch();
    for (final doc in snap.docs) {
      if (doc.data()['boardedAt'] != null) {
        batch.update(doc.reference, {'status': BookingStatus.completed});
      }
    }
    await batch.commit();
  }

  Future<void> signOut() async {
    await LocationService.instance.stopTracking();
    await authC.signOut();
  }

  @override
  void onClose() {
    _tripSub?.cancel();
    _scheduleSub?.cancel();
    super.onClose();
  }
}
