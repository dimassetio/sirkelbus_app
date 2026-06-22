import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/route_model.dart';
import '../../../../data/models/schedule_model.dart';
import '../../../../data/providers/booking_provider.dart';

enum ScheduleDirection { toSchool, fromSchool }

class UserScheduleController extends GetxController {
  final schedules = <ScheduleModel>[].obs;
  final routeMap = <String, RouteModel>{};
  final isLoading = true.obs;
  final isBooking = false.obs;
  final selectedDate = DateTime.now().obs;
  final selectedDirection = ScheduleDirection.toSchool.obs;

  StreamSubscription<List<ScheduleModel>>? _scheduleSub;

  List<ScheduleModel> get filteredSchedules {
    return schedules
        .where((s) => s.runsOn(selectedDate.value) && _matchesDirection(s))
        .toList();
  }

  bool _matchesDirection(ScheduleModel s) {
    final d = (s.routeDirection ?? '').toLowerCase();
    if (d.isEmpty) return true;
    switch (selectedDirection.value) {
      case ScheduleDirection.toSchool:
        return d.contains('pergi') ||
            d.contains('berangkat') ||
            d.contains('to_school') ||
            d.contains('to-school') ||
            d.contains('go');
      case ScheduleDirection.fromSchool:
        return d.contains('pulang') ||
            d.contains('kembali') ||
            d.contains('from_school') ||
            d.contains('from-school') ||
            d.contains('back');
    }
  }

  String routeNameFor(ScheduleModel s) =>
      routeMap[s.routeId]?.name ?? s.name ?? s.routeId ?? '-';

  List<String> stopIdsFor(ScheduleModel schedule) =>
      routeMap[schedule.routeId]?.stopIds ?? [];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments == 'fromSchool') {
      selectedDirection(ScheduleDirection.fromSchool);
    }
    _load();
  }

  Future<void> _load() async {
    isLoading(true);
    final routes = await RouteModel.streamAll().first;
    for (final r in routes) {
      if (r.id != null) routeMap[r.id!] = r;
    }
    _scheduleSub = ScheduleModel.streamAll().listen((data) {
      schedules.assignAll(data);
      isLoading(false);
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF14213D)),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedDate(picked);
  }

  Future<void> book({
    required ScheduleModel schedule,
    required String pickupStopId,
  }) async {
    isBooking(true);
    final serviceDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final (_, error) = await BookingProvider.instance.createBooking(
      scheduleId: schedule.id!,
      pickupStopId: pickupStopId,
      serviceDate: serviceDate,
    );
    isBooking(false);

    if (error != null) {
      Get.snackbar('Gagal', error);
      return;
    }

    Get.back();
    Get.snackbar(
      'Berhasil',
      'Tiket berhasil dipesan!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF22C55E),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    _scheduleSub?.cancel();
    super.onClose();
  }
}
