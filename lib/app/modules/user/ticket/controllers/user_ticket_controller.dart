import 'dart:async';

import 'package:get/get.dart';

import '../../../../data/models/booking_model.dart';
import '../../../../data/models/route_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/models/stop_model.dart';
import '../../../auth/controllers/auth_controller.dart';

class UserTicketController extends GetxController {
  final bookings = <BookingModel>[].obs;
  final isLoading = true.obs;

  final _scheduleMap = <String, ScheduleModel>{};
  final _routeMap = <String, RouteModel>{};
  final _stopMap = <String, StopModel>{};

  StreamSubscription<List<BookingModel>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final userId = authC.user.id;
    if (userId == null || userId.isEmpty) {
      isLoading(false);
      return;
    }

    final schedules = await ScheduleModel.streamAll().first;
    for (final s in schedules) {
      if (s.id != null) _scheduleMap[s.id!] = s;
    }

    final routes = await RouteModel.streamAll().first;
    for (final r in routes) {
      if (r.id != null) _routeMap[r.id!] = r;
    }

    _sub = BookingModel.streamByUser(userId).listen((data) async {
      final missingStopIds = data
          .map((b) => b.pickupStopId)
          .whereType<String>()
          .where((id) => id.isNotEmpty && !_stopMap.containsKey(id))
          .toSet()
          .toList();

      if (missingStopIds.isNotEmpty) {
        final stops = await StopModel.getByIds(missingStopIds);
        for (final s in stops) {
          if (s.id != null) _stopMap[s.id!] = s;
        }
      }

      bookings.assignAll(data);
      isLoading(false);
    });
  }

  ScheduleModel? scheduleFor(BookingModel b) => _scheduleMap[b.scheduleId];

  String routeNameFor(BookingModel b) {
    final schedule = scheduleFor(b);
    return _routeMap[schedule?.routeId]?.name ?? schedule?.name ?? '-';
  }

  String departureTimeFor(BookingModel b) =>
      scheduleFor(b)?.departureTime ?? '-';

  String pickupStopNameFor(BookingModel b) =>
      _stopMap[b.pickupStopId]?.name ?? '-';

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
